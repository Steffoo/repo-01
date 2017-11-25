FROM openjdk:8
WORKDIR /
ADD tomcat/tomcat-6.0.5-jar-with-dependencies.jar tomcat-6.0.5-jar-with-dependencies.jar
ADD tomcat/webapps/ webapps/
ADD tomcat/conf/ conf/
EXPOSE 8081
EXPOSE 8082
CMD nohup java -jar tomcat-6.0.5-jar-with-dependencies.jar &
