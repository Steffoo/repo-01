cmd="java -jar tomcat-6.0.5-$1.jar"
process=$(ps aux | grep "$cmd" | head -n1 | cut -d " " -f 4)
echo $process
if ps -p $process > /dev/null
then
	kill -9 $process
fi

