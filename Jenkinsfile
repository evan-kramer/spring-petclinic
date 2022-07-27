pipeline {
    agent {
        docker {
            image 'maven:3.8.1-adoptopenjdk-11'
            args '-v /root/.m2:/root/.m2'
        }
    }
    options {
        skipStagesAfterUnstable()
    }
    stages {
        stage('SonarQube') {
            environment {
                def scanner_home = tool 'sonarqube-scanner'
            }
            steps {
                withSonarQubeEnv('sonar_server') {
                    // sh 'mvn clean package sonar:sonar'
					sh 'echo ${scanner_home}'
                    sh 'ls -l /var/jenkins_home/'
                    println "${env.SONAR_HOST_URL}"
					sh '${scanner_home}/bin/sonar-scanner'
					// sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.7.0.1746:sonar'
                }
            }
        }
        stage('Build') {
            steps {
                sh 'mvn -f /var/jenkins_home/workspace/17646-assignment1/Assignments/1/test/spring-petclinic/pom.xml -B -DskipTests -Dserver.port=8081 clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn -f /var/jenkins_home/workspace/17646-assignment1/Assignments/1/test/spring-petclinic/pom.xml test'
            }
        }
        stage('Deliver') { 
            steps {
                sh 'mvn -f /var/jenkins_home/workspace/17646-assignment1/Assignments/1/test/spring-petclinic/pom.xml package'
                sh 'java -Dserver.port=8081 -jar /var/jenkins_home/workspace/17646-assignment1/Assignments/1/test/spring-petclinic/target/spring-petclinic-2.7.0-SNAPSHOT.jar &'
            }
        }
    }
} 
