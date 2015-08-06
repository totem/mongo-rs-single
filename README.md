# mongo-rs-single
Mongo Replica Set with single docker node. This is useful if you are using mongo connnctor and need a quick way to
start a one node mongo replica set.

## Running
```
docker run -h mongo-rs-single --rm -v ~/mongo-docker:/data/db -it -P  totem/mongo-rs-single
```
