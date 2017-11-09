node {
	//------------------------------------------------------------------------
    stage name: 'clean'
	//------------------------------------------------------------------------
	
	checkout scm
	
	sh "cd 'tomcat'"
	
	// String gitCommit = sh (returnStdout: true, script: 'git rev-parse HEAD').trim()
    // gradle "clean build publish -Prevision=${buildNr}--${gitCommit}"
	
	buildNr = '${BUILD_NUMBER}'
	
	env.JAVA_HOME="${tool 'JDK1.8.0_151'}"
    env.PATH="${env.JAVA_HOME}/bin:${env.PATH}"
    sh 'java -version'
    
	mvn 'clean'
	
	//------------------------------------------------------------------------
    stage name: 'compile'
	//------------------------------------------------------------------------

    
    mvn 'compile'
    
    //------------------------------------------------------------------------
    stage name: 'assembly'
	//------------------------------------------------------------------------
	
	mvn 'assembly:single'
    

} 

