#!/bin/bash -e
set -m

function mongo_wait {
    RET=1
    while [[ RET -ne 0 ]]; do
        echo "=> Waiting for confirmation of MongoDB service startup"
        sleep 5
        mongo admin --eval "help" >/dev/null 2>&1
        RET=$?
    done
}

# Init replica set
sed -i s/#replSet=setname/replSet=default/  /etc/mongod.conf

mongodb_cmd="mongod"
cmd="$mongodb_cmd --httpinterface --rest --replSet=default"
if [ "$AUTH" == "yes" ]; then
    cmd="$cmd --auth"
fi

if [ "$JOURNALING" == "no" ]; then
    cmd="$cmd --nojournal"
fi

if [ "$OPLOG_SIZE" != "" ]; then
    cmd="$cmd --oplogSize $OPLOG_SIZE"
fi

$cmd &

mongo_wait

if [ ! -f /data/db/.mongodb_init ]; then
    echo "rs.initiate()" | mongo admin
    mongo_wait
    
    PASS=${MONGODB_PASS:-$(pwgen -s 12 1)}
    _word=$( [ ${MONGODB_PASS} ] && echo "preset" || echo "random" )
    echo "=> Creating an admin user with a ${_word} password in MongoDB"
    mongo admin --eval "db.createUser({user: 'admin', pwd: '$PASS', roles:[{role:'root',db:'admin'}]});"

    echo "=> Done!"
    echo "========================================================================"
    echo "You can now connect to this MongoDB server using:"
    echo ""
    echo "    mongo admin -u admin -p $PASS --host <host> --port <port>"
    echo ""
    echo "Please remember to change the above password as soon as possible!"
    echo "========================================================================"
    touch /data/db/.mongodb_init
fi

fg
