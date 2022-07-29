pipeline {
    agent any
    tools { 
        maven 'maven' 
        jdk 'jdk' 
    }
    options {
        skipStagesAfterUnstable()
    }
    stages {
        stage('SonarQube') {
            environment {
                scanner_home = tool 'sonarqube-scanner'
            }
            steps {
                withSonarQubeEnv('sonar_server') {
                    sh 'echo ${JAVA_HOME}'
                    sh 'echo ${scanner_home}'
                    sh 'mvn clean verify sonar:sonar -Dsonar.login={$SONAR_LOGIN} -Dsonar.host.url=http://sonarqube:9000 -Dsonar.analysis.mode=publish -Dsonar.projectKey=17646-assignment1'
                }
            }
        }
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests -Dserver.port=8081 clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Deliver') { 
            steps {
                sh 'mvn package'
                sh 'java -Dserver.port=8081 -jar /var/jenkins_home/workspace/17646-assignment1/spring-petclinic/target/spring-petclinic-2.7.0-SNAPSHOT.jar'
            }
        }
    }
    post {
        always {
            junit(
                allowEmptyResults: true,
                testResults: '*/test-reports/.xml'
            )
        }
   } 
}