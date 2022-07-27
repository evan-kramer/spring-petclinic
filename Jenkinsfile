pipeline {
    agent any 
	//agent {
    //    docker {
    //        image 'maven:3.8.1-adoptopenjdk-11'
    //        args '-v /root/.m2:/root/.m2'
    //    }
    //}
    options {
        skipStagesAfterUnstable()
    }
    stages {
        stage('SonarQube') {
            environment {
                def scanner_home = tool 'sonarqube-scanner'
				//def scanner_home = tool name: 'sonarqube-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
            }
            steps {
                withSonarQubeEnv(installationName: 'sonar_server') {
					sh 'export SONAR_RUNNER_HOME=/opt/sonar-runner'
					sh 'export PATH=$PATH:$SONAR_RUNNER_HOME/bin'
					sh 'echo ${scanner_home}'
					sh 'echo "sonar.login=admin" >> ${scanner_home}/conf/sonar-scanner.properties'
					sh 'echo "sonar.password=17646ass1" >> ${scanner_home}/conf/sonar-scanner.properties'
					
					//sh 'echo ${JAVA_HOME}'
                    //sh 'ls -l /var/jenkins_home/tools'
					//sh 'ls -l ${scanner_home}/bin'
					sh '${scanner_home}/bin/sonar-scanner'
                }
            }
        }
        stage('Build') {
            steps {
                //sh 'mvn -f /var/jenkins_home/workspace/17646-assignment1/Assignments/1/test/spring-petclinic/pom.xml -B -DskipTests -Dserver.port=8081 clean package'
				sh 'mvn -B -DskipTests -Dserver.port=8081 clean package'
            }
        }
        stage('Test') {
            steps {
                //sh 'mvn -f /var/jenkins_home/workspace/17646-assignment1/Assignments/1/test/spring-petclinic/pom.xml test'
				sh 'mvn test'
            }
        }
        stage('Deliver') { 
            steps {
                //sh 'mvn -f /var/jenkins_home/workspace/17646-assignment1/Assignments/1/test/spring-petclinic/pom.xml package'
                sh 'mvn package'
				//sh 'java -Dserver.port=8081 -jar /var/jenkins_home/workspace/17646-assignment1/Assignments/1/test/spring-petclinic/target/spring-petclinic-2.7.0-SNAPSHOT.jar &'
				sh 'java -Dserver.port=8081 -jar target/spring-petclinic-2.7.0-SNAPSHOT.jar &'
            }
        }
    }
} 
