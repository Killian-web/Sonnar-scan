pipeline {

    /*****************************************************************
     * Jenkins agent
     * Runs on any available Jenkins worker node
     *****************************************************************/
    agent any

    /*****************************************************************
     * Global pipeline options (industry standard)
     *****************************************************************/
    options {
        timestamps()                 // Add timestamps to logs
        disableConcurrentBuilds()    // Prevent parallel deploys
        timeout(time: 60, unit: 'MINUTES') // Prevent stuck pipelines
        ansiColor('xterm')
    }

    /*****************************************************************
     * Global environment variables
     * These define staging behavior
     *****************************************************************/
    environment {

        // AWS / EKS
        AWS_REGION     = 'us-east-1'
        AWS_ACCOUNT_ID = '123456789'
        EKS_CLUSTER    = 'enco-staging-cluster'
        KUBE_NAMESPACE = 'staging'

        // Application
        APP_NAME       = 'account-service'

        // Docker
        ECR_REPO       = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}"

        // Versioning
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
    }

    stages {

        /*************************************************************
         * 1️ SOURCE CODE CHECKOUT
         *************************************************************/
        stage('Checkout Source') {
            steps {
                echo "Checking out staging branch source code"

                git branch: 'staging',
                    url: 'https://github.com/yourorg/enco-bank-microservices.git'
            }
        }

        /*************************************************************
         * 2️ MAVEN BUILD & UNIT TESTS
         *************************************************************/
        stage('Build & Unit Tests') {
            steps {
                echo "Running Maven clean build and unit tests"

                sh '''
                mvn clean verify \
                    -DskipITs=false \
                    -B
                '''
            }
        }

        /*************************************************************
         * 3️ INTEGRATION TESTS
         *************************************************************/
        stage('Integration Tests') {
            steps {
                echo "Running integration tests"

                sh '''
                mvn failsafe:integration-test failsafe:verify
                '''
            }
        }

        /*************************************************************
         * 4️ STATIC CODE QUALITY (SONAR)
         *************************************************************/
        stage('Code Quality Scan') {
            steps {
                echo "Running SonarQube scan"

                withSonarQubeEnv('sonarqube-server') {
                    sh '''
                    mvn sonar:sonar \
                      -Dsonar.projectKey=enco-${APP_NAME}-staging
                    '''
                }
            }
        }

        /*************************************************************
         * 5️ BUILD DOCKER IMAGE
         *************************************************************/
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image"

                sh '''
                docker build \
                  -t ${APP_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        /*************************************************************
         * 6️CONTAINER SECURITY SCAN
         *************************************************************/
        stage('Container Security Scan') {
            steps {
                echo "Scanning Docker image with Trivy"

                sh '''
                trivy image \
                  --severity HIGH,CRITICAL \
                  --exit-code 1 \
                  ${APP_NAME}:${IMAGE_TAG}
                '''
            }
        }

        /*************************************************************
         * 7️ PUSH IMAGE TO AWS ECR
         *************************************************************/
        stage('Push Image to ECR') {
            steps {
                echo "Authenticating and pushing image to ECR"

                sh '''
                aws ecr get-login-password --region ${AWS_REGION} | docker login \
                    --username AWS \
                    --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

                docker tag ${APP_NAME}:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
                docker push ${ECR_REPO}:${IMAGE_TAG}
                '''
            }
        }

        /*************************************************************
         * 8️ DEPLOY TO STAGING EKS (HELM)
         *************************************************************/
        stage('Deploy to Staging EKS') {
            steps {
                echo "Deploying to staging EKS using Helm"

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

        /*************************************************************
         * 9️ SMOKE & HEALTH CHECKS
         *************************************************************/
        stage('Health Checks') {
            steps {
                echo "Running post-deployment health checks"

                sh '''
                curl -f https://staging.encobank.com/health
                curl -f https://staging.encobank.com/api/accounts/health
                '''
            }
        }
    }

    /*****************************************************************
     * POST PIPELINE ACTIONS
     *****************************************************************/
    post {

        success {
            echo "✅ STAGING DEPLOYMENT SUCCESSFUL"

            slackSend(
                channel: '#deployments',
                message: " *STAGING DEPLOYMENT SUCCESS*\n${APP_NAME}:${IMAGE_TAG}\n${env.BUILD_URL}"
            )
        }

        failure {
            echo " STAGING DEPLOYMENT FAILED"

            slackSend(
                channel: '#deployments',
                message: " *STAGING DEPLOYMENT FAILED*\n${env.BUILD_URL}"
            )
        }

        always {
            cleanWs()
        }
    }
}
