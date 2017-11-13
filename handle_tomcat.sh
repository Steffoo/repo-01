#!/bin/bash
cidir=/var/lib/jenkins
proddir=/var/lib/jenkins/production
if [ "$1" == "CI" ]; then
  cd $cidir
else
  cd $proddir
fi
cmd="java -jar tomcat-6.0.5-$1.jar"
ps | grep "$cmd" | awk '{print $1}' | xargs kill -9 || true

BUILD_ID=do_not_kill_me
java -jar tomcat-6.0.5-$1.jar &
exit
