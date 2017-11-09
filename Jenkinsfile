node {
	//------------------------------------------------------------------------
    stage name: 'clean'
	//------------------------------------------------------------------------
	
	checkout scm
	
	sh "cd 'tomcat'"
	
	// String gitCommit = sh (returnStdout: true, script: 'git rev-parse HEAD').trim()
    // gradle "clean build publish -Prevision=${buildNr}--${gitCommit}"
	
	buildNr = '${BUILD_NUMBER}'
	
	env.JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
    env.PATH="${env.JAVA_HOME}/bin:${env.PATH}"
    sh 'java -version'
    
	sh "mvn 'clean'"
	
	//------------------------------------------------------------------------
    stage name: 'compile'
	//------------------------------------------------------------------------

    
    sh "mvn 'compile'"
    
    //------------------------------------------------------------------------
    stage name: 'assembly'
	//------------------------------------------------------------------------
	
	sh "mvn 'assembly:single'"
    

} 

