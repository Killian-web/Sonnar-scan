pipeline {
    agent any

    tools {
        maven 'Maven3'
        jdk 'JDK11'
    }

    environment {
        // Nexus (Maven only)
        NEXUS_REPO_URL = 'http://16.16.91.8:8081/repository/maven-releases/'
        
        // SonarQube
        SONAR_HOST_URL = 'http://13.51.251.109:9000'

        // Docker Hub
        DOCKERHUB_USERNAME = '2000nn'
        IMAGE_NAME = 'account-service'
        FULL_IMAGE_NAME = "${DOCKERHUB_USERNAME}/account-service"
    }

    stages {

        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Build Application') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('SonarQube Code Analysis') {
            steps {
                withSonarQubeEnv('enco-sonarqube') {
                    sh """
                      mvn sonar:sonar \
                      -Dsonar.projectKey=account-service \
                      -Dsonar.projectName=account-service \
                      -Dsonar.host.url=${SONAR_HOST_URL}
                    """
                }
            }
        }

        stage('Publish JAR to Nexus') {
            steps {
                sh 'mvn deploy -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                  docker build -t ${FULL_IMAGE_NAME}:${BUILD_NUMBER} .
                  docker tag ${FULL_IMAGE_NAME}:${BUILD_NUMBER} ${FULL_IMAGE_NAME}:latest
                """
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                withDockerRegistry(
                    credentialsId: 'dockerhub-credentials',
                    url: 'https://index.docker.io/v1/'
                ) {
                    sh """
                      docker push ${FULL_IMAGE_NAME}:${BUILD_NUMBER}
                      docker push ${FULL_IMAGE_NAME}:latest
                    """
                }
            }
        }
    }

    post {
        success {
            emailext (
                subject: "SUCCESS: Account Service Build #${BUILD_NUMBER}",
                body: """
                ✅ Build SUCCESSFUL

                Job: ${JOB_NAME}
                Build Number: ${BUILD_NUMBER}

                Docker Image:
                ${FULL_IMAGE_NAME}:${BUILD_NUMBER}

                Jenkins URL:
                ${BUILD_URL}
                """,
                to: 'devops@encobank.com'
            )
        }

        failure {
            emailext (
                subject: "FAILED: Account Service Build #${BUILD_NUMBER}",
                body: """
                ❌ Build FAILED

                Job: ${JOB_NAME}
                Build Number: ${BUILD_NUMBER}

                Jenkins URL:
                ${BUILD_URL}
                """,
                to: 'rajpatel.enco@atomicmail.io'
            )
        }
    }
}
