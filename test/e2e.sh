#!/usr/bin/env bash

SCRIPT_DIR=${BASH_SOURCE%/*}

echo "Deleting downloaded binaries"
rm $SCRIPT_DIR/../bin/pb
rm $SCRIPT_DIR/../bin/duffle
rm $SCRIPT_DIR/../tmp/build-service-0.1.0.tgz

./pbsetup
./pbsetup create gke-cluster
./pbsetup delete gke-cluster
