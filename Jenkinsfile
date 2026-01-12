pipeline {
    agent any
    
    tools {
        maven 'Maven3'
        jdk 'JDK11'
    }
    
    environment {
        NEXUS_URL = 'http://13.49.138.85:8081'
        SONAR_HOST_URL = 'http://16.171.45.144:9000'
        DOCKER_REGISTRY = '13.49.138.85:8082'
        IMAGE_NAME      = 'account-service'
    }
    
   stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    // DO NOT fail pipeline if reports do not exist
                    junit allowEmptyResults: true,
                          testResults: 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('enco-sonarqube') {
                    sh '''
                      mvn sonar:sonar \
                      -Dsonar.projectKey=account-service \
                      -Dsonar.projectName=account-service \
                      -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                      -Dsonar.host.url=$SONAR_HOST_URL
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${BUILD_NUMBER}")
                }
            }
        }

        stage('Push to Nexus') {
            steps {
                script {
                    docker.withRegistry("http://${DOCKER_REGISTRY}", 'nexus-admin') {
                        docker.image("${IMAGE_NAME}:${BUILD_NUMBER}").push()
                    }
                }
            }
        }
    }
    
    post {
        success {
            emailext (
                subject: "SUCCESS: Account Service Build #${BUILD_NUMBER}",
                body: """
                Build SUCCESSFUL
                Job: ${JOB_NAME}
                Build: ${BUILD_NUMBER}
                URL: ${BUILD_URL}
                """,
                to: 'devops@encobank.com'
            )
        }

        failure {
            emailext (
                subject: "FAILED: Account Service Build #${BUILD_NUMBER}",
                body: """
                Build FAILED
                Job: ${JOB_NAME}
                Build: ${BUILD_NUMBER}
                URL: ${BUILD_URL}
                """,
                to: 'devops@encobank.com'
            )
        }
    }
}
