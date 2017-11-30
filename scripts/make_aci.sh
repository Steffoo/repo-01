#!/bin/bash
if [ "$1" == "CI" ]; then
	workdir=/var/lib/jenkins
else
	workdir=/var/lib/jenkins/production
fi
cd $workdir
user=$(whoami)
acifile=tomcat.aci
rm -f tomcat.aci || true
sudo acbuild begin
sudo acbuild dependency add quay.io/extendedmind/openjdk:openjdk-8u121
sudo acbuild port add tomcat-http tcp 8081
sudo acbuild copy $workdir/tomcat-6.0.5-$1.jar /tmp/tomcat.jar
sudo acbuild copy-to-dir $workdir/webapps/* /webapps
sudo acbuild copy-to-dir $workdir/conf/* /conf
sudo acbuild set-exec -- nohup java -jar /tmp/tomcat.jar
sudo acbuild set-name apache.org/tomcat
sudo acbuild annotation add authors "Max Jando<max.jando1@stud.hs-mannheim.de>, Felix Hefner<mail@felixhefner.de>"
sudo acbuild write $acifile
sudo acbuild end
sudo chown $user $acifile