#!/bin/bash

uc=${1^^}

# Stop running tomcat-container/pot
sudo rkt stop --force $(sudo rkt list | grep tomcat-$1 | cut -f 1)

# Remove all exited container/pot

sudo rkt rm $(sudo rkt list --no-legend | cut -f 1)

# Build new .aci - file
/var/lib/jenkins/make_aci.sh $uc

# Run created image
sudo rkt run --net=host --insecure-options=image tomcat.aci --name=tomcat-ci &