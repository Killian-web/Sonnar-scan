pipeline {

    /*****************************************************************
     * Jenkins agent
     *****************************************************************/
    agent any

    /*****************************************************************
     * Global pipeline options
     *****************************************************************/
    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 60, unit: 'MINUTES')
    }

    /*****************************************************************
     * Global environment variables
     *****************************************************************/
    environment {

        // AWS / EKS
        AWS_REGION     = 'eu-north-1'
        AWS_ACCOUNT_ID = '560740997447'
        EKS_CLUSTER    = 'enco-staging-cluster'
        KUBE_NAMESPACE = 'staging'

        // Application
        APP_NAME = 'account-service'

        // Docker / ECR
        ECR_REPO  = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {

        /*************************************************************
         * 1. SOURCE CODE CHECKOUT
         *************************************************************/
        stage('Checkout Source') {
            steps {
                echo "Checking out staging branch source code"

                git branch: 'staging',
                    url: 'https://github.com/Killian-web/Sonnar-scan.git'
            }
        }

        /*************************************************************
         * 2. MAVEN BUILD & UNIT TESTS
         *************************************************************/
        stage('Build & Unit Tests') {
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                    sh '''
                    mvn clean verify \
                        -DskipITs=false \
                        -B
                    '''
                }
            }
        }

        /*************************************************************
         * 3. INTEGRATION TESTS
         *************************************************************/
        // stage('Integration Tests') {
        //     steps {
        //         wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
        //             sh '''
        //             mvn failsafe:integration-test failsafe:verify
        //             '''
        //         }
        //     }
        // }

        /*************************************************************
         * 4. SONARQUBE CODE QUALITY
         *************************************************************/
        stage('Code Quality Scan') {
            steps {
                echo "Running SonarQube scan"

                withSonarQubeEnv('sonarqube-server') {
                    wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                        sh '''
                        mvn sonar:sonar \
                          -Dsonar.projectKey=enco-${APP_NAME}-staging
                        '''
                    }
                }
            }
        }

        /*************************************************************
         * 5. BUILD DOCKER IMAGE
         *************************************************************/
        stage('Build Docker Image') {
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                    sh '''
                    docker build \
                      -t ${APP_NAME}:${IMAGE_TAG} .
                    '''
                }
            }
        }

        /*************************************************************
         * 6. CONTAINER SECURITY SCAN (TRIVY)
         *************************************************************/
        stage('Container Security Scan') {
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                    sh '''
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      ${APP_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        /*************************************************************
         * 7. PUSH IMAGE TO AWS ECR
         *************************************************************/
        stage('Push Image to ECR') {
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                    sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | docker login \
                        --username AWS \
                        --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

                    docker tag ${APP_NAME}:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
                    docker push ${ECR_REPO}:${IMAGE_TAG}
                    '''
                }
            }
        }

        /*************************************************************
         * 8. DEPLOY TO STAGING EKS (HELM)
         *************************************************************/
        stage('Deploy to Staging EKS') {
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                    sh '''
                    aws eks update-kubeconfig \
                      --region ${AWS_REGION} \
                      --name ${EKS_CLUSTER}

                    helm upgrade --install ${APP_NAME} ./charts/${APP_NAME} \
                      --namespace ${KUBE_NAMESPACE} \
                      --create-namespace \
                      --set image.repository=${ECR_REPO} \
                      --set image.tag=${IMAGE_TAG} \
                      --values values/staging.yaml \
                      --atomic \
                      --wait \
                      --timeout 10m
                    '''
                }
            }
        }

        /*************************************************************
         * 9. HEALTH CHECKS
         *************************************************************/
        stage('Health Checks') {
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                    sh '''
                    curl -f https://staging.encobank.com/health
                    curl -f https://staging.encobank.com/api/accounts/health
                    '''
                }
            }
        }
    }

    /*****************************************************************
     * POST PIPELINE ACTIONS
     *****************************************************************/
    post {

        success {
            echo " STAGING DEPLOYMENT SUCCESSFUL"

            slackSend(
                channel: '#deployments',
                message: "*STAGING DEPLOYMENT SUCCESS*\n${APP_NAME}:${IMAGE_TAG}\n${env.BUILD_URL}"
            )
        }

        failure {
            echo " STAGING DEPLOYMENT FAILED"

            slackSend(
                channel: '#deployments',
                message: "*STAGING DEPLOYMENT FAILED*\n${env.BUILD_URL}"
            )
        }

        always {
            cleanWs()
        }
    }
}
