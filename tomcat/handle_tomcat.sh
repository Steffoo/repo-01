#!/bin/bash
cidir=/var/lib/jenkins
proddir=/var/lib/jenkins/production
workspace=/var/lib/jenkins/workspace/Tomcat_$1_Build
jar_name=tomcat-6.0.5-$1.jar
if [ "$1" == "CI" ]; then
  cd $cidir
else
  cd $proddir
fi
cmd="java -jar $jar_name"
ps | grep "$cmd" | awk '{print $1}' | xargs kill -9 || true

cp $workspace/tomcat/target/tomcat-6.0.5-jar-with-dependencies.jar $jar_name

BUILD_ID=do_not_kill_me
java -jar $jar_name &
exit
