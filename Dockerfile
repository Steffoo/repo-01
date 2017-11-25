FROM openjdk:8
WORKDIR /
ADD tomcat-6.0.5-jar-with-dependencies.jar tomcat-6.0.5-jar-with-dependencies.jar
ADD webapps/ webapps/
ADD conf/ conf/
EXPOSE 8081
EXPOSE 8082
CMD nohup java -jar tomcat-6.0.5-jar-with-dependencies.jar &
