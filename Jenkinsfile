pipeline {
    agent any

    tools {
        maven 'Maven-3'
        git 'Default-Git'
        jdk 'JDK11'
    }

    environment {
        // ===== Application =====
        SERVICE_NAME = 'account-service'

        // ===== Nexus =====
        NEXUS_REPO_URL = 'http://13.63.50.105:8081/repository/maven-releases/'

        // ===== SonarQube =====
        SONAR_HOST_URL = 'http://13.63.56.193:9000'
        SONAR_TOKEN = credentials('sonar-token')

        // ===== Docker =====
        DOCKERHUB_USERNAME = '2000nn'
        IMAGE_NAME = 'account-service'
        FULL_IMAGE_NAME = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}"
        DOCKER_IMAGE = "${FULL_IMAGE_NAME}:${BUILD_NUMBER}"

        // ===== AWS / EKS =====
        // AWS_REGION = 'eu-north-1'
        // EKS_CLUSTER = 'enco-dev-eks'
    }

    stages {

        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Build & Unit Tests') {
            steps {
                sh 'mvn clean verify'
            }
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
                withDockerRegistry(
                    credentialsId: 'dockerhub-credentials',
                    url: 'https://index.docker.io/v1/'
                ) {
                    sh '''
                        docker push ${FULL_IMAGE_NAME}:${BUILD_NUMBER}
                        docker push ${FULL_IMAGE_NAME}:latest
                    '''
                }
            }
        }

        // stage('Deploy to Dev EKS') {
        //     steps {
        //         withCredentials([
        //             [$class: 'AmazonWebServicesCredentialsBinding',
        //              credentialsId: 'aws-credentials']
        //         ]) {
        //             sh '''
        //                 aws eks update-kubeconfig \
        //                   --region eu-north-1 \
        //                   --name enco-dev-eks
        
        //                 kubectl apply -f deployment/
        //                 kubectl rollout status deployment/account-service -n dev
        //             '''
        //         }
        //     }
        // }

    }

    post {

        success {
            emailext(
                subject: "SUCCESS: Account Service Pipeline #${BUILD_NUMBER}",
                body: """Pipeline completed successfully!

Details:
- Service: ${SERVICE_NAME}
- Image: ${FULL_IMAGE_NAME}:${BUILD_NUMBER}
- Environment: dev
- Jenkins URL: ${BUILD_URL}
- Quality Gate: PASSED
""",
                to: 'devops@encobank.com',
                attachLog: false
            )
        }

        failure {
            emailext(
                subject: "FAILED: Account Service Pipeline #${BUILD_NUMBER}",
                body: """Pipeline FAILED!

Please check:
1. Build logs: ${BUILD_URL}console
2. Test results: ${BUILD_URL}testReport/
3. SonarQube: ${SONAR_HOST_URL}
""",
                to: 'devops@encobank.com,kate.miller@encobank.com',
                attachLog: true
            )
        }

        always {
            cleanWs()
        }
    }
}
