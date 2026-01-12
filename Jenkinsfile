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
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean compile'
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
                    sh 'mvn sonar:sonar'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("account-service:${env.BUILD_ID}")
                }
            }
        }
        
        stage('Push to Nexus') {
            steps {
                script {
                    docker.withRegistry("http://${DOCKER_REGISTRY}", 'nexus-admin') {
                        docker.image("account-service:${env.BUILD_ID}").push()
                    }
                }
            }
        }
    }
    
    post {
        success {
            emailext (
                subject: "SUCCESS: Account Service Build #${env.BUILD_NUMBER}",
                body: "Build ${env.BUILD_URL} completed successfully!",
                to: 'devops@encobank.com'
            )
        }
        failure {
            emailext (
                subject: "FAILED: Account Service Build #${env.BUILD_NUMBER}",
                body: "Build ${env.BUILD_URL} failed! Please check.",
                to: 'devops@encobank.com'
            )
        }
    }
}
