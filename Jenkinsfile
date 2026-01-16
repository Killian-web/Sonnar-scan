pipeline {
    agent any

    tools {
        maven 'Maven-3'
        git 'Default-Git'
        jdk 'JDK11'
    }

    environment {
        NEXUS_REPO_URL = 'http://16.16.91.8:8081/repository/maven-releases/'
        SONAR_HOST_URL = 'http://13.51.251.109:9000'
        SONAR_TOKEN = credentials('sonar-token')
        DOCKERHUB_USERNAME = '2000nn'
        IMAGE_NAME = 'account-service'
        FULL_IMAGE_NAME = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}"
    }

    stages {
        stage('Checkout Source') {
            steps { checkout scm }
        }

        stage('Build & Unit Tests') {
            steps { sh 'mvn clean verify' }
            post {
                always {
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
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }

        stage('Build & Publish to Nexus') {
            steps {
                sh '''
                  mvn clean deploy -DskipTests \
                  --settings /var/lib/jenkins/.m2/settings.xml
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                  docker build -t ${FULL_IMAGE_NAME}:${BUILD_NUMBER} .
                  docker tag ${FULL_IMAGE_NAME}:${BUILD_NUMBER} ${FULL_IMAGE_NAME}:latest
                '''
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                withDockerRegistry(credentialsId: 'dockerhub-credentials', url: 'https://index.docker.io/v1/') {
                    sh '''
                      docker push ${FULL_IMAGE_NAME}:${BUILD_NUMBER}
                      docker push ${FULL_IMAGE_NAME}:latest
                    '''
                }
            }
        }
    }

    post {
        success {
            emailext(
                subject: "SUCCESS: Build #${BUILD_NUMBER}",
                body: " Build SUCCESSFUL\nJenkins URL: ${BUILD_URL}",
                to: 'devops@encobank.com'
            )
        }
        failure {
            emailext(
                subject: "FAILED: Build #${BUILD_NUMBER}",
                body: " Build FAILED\nJenkins URL: ${BUILD_URL}",
                to: 'devops@encobank.com'
            )
        }
    }
}
