node {
	//------------------------------------------------------------------------
    stage name: 'clean'
	//------------------------------------------------------------------------
	
	checkout scm
	
	// String gitCommit = sh (returnStdout: true, script: 'git rev-parse HEAD').trim()
    // gradle "clean build publish -Prevision=${buildNr}--${gitCommit}"
	
	buildNr = '${BUILD_NUMBER}'
	
	env.JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
    env.PATH="${env.JAVA_HOME}/bin:${env.PATH}"
    sh 'java -version'
    
	sh "cd 'tomcat' ; mvn 'clean'"
	
	//------------------------------------------------------------------------
    stage name: 'compile'
	//------------------------------------------------------------------------

    
    sh "cd 'tomcat' ; mvn 'compile'"

    //------------------------------------------------------------------------
    stage name: 'test'
    //------------------------------------------------------------------------
    	
    sh "cd 'tomcat' ; mvn test"
    
    //------------------------------------------------------------------------
    stage name: 'assembly'
	//------------------------------------------------------------------------
	
	sh "cd 'tomcat' ; mvn 'assembly:single'"
    

} 

