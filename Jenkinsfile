pipeline {
    agent any

    parameters {
        string(name: 'KUBE_NAMESPACE', defaultValue: 'default', description: 'Kubernetes namespace to deploy to')
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Docker image tag to deploy')
        booleanParam(name: 'SKIP_VALIDATION', defaultValue: false, description: 'Skip kubectl OpenAPI validation')
    }

    environment {
        DOCKER_IMAGE   = "vijayshinde2157/calculator-app:${params.IMAGE_TAG}"
        DOCKER_USER    = credentials('docker-username') // Docker Hub username
        DOCKER_PASS    = credentials('docker-password') // Docker Hub password
        KUBE_API_URL   = credentials('kube-api-url')
        KUBE_TOKEN     = credentials('kube-token')
    }
    

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-creds-id', url: 'https://github.com/vijayns2157/calculator-app.git'
            }
        }
        stage('Use Minikube Docker') {
            steps {
                sh 'eval $(minikube docker-env)'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh '''
                echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                docker build -t $DOCKER_IMAGE .
                docker push $DOCKER_IMAGE
                '''
            }
        }

        stage('Install kubectl & envsubst') {
            steps {
                sh '''
                apk add --no-cache bash curl kubectl gettext
                '''
            }
        }
        stage('Prepare Deployment') {
            steps {
                sh '''
                export DOCKER_IMAGE=$DOCKER_IMAGE
                envsubst < deployment.yml > updated-deployment.yml
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def validateFlag = params.SKIP_VALIDATION ? "--validate=false" : ""
                    sh "kubectl apply -f updated-deployment.yml ${validateFlag}"
                }
            }
        }

        stage('Verify Rollout') {
            steps {
                sh '''
                kubectl rollout status deployment/calculator-app -n ${KUBE_NAMESPACE} || echo "Rollout status check failed"
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Successfully built and deployed $DOCKER_IMAGE to namespace ${KUBE_NAMESPACE}"
        }
        failure {
            echo "❌ Pipeline failed. Check Docker build, push, or Kubernetes deployment steps."
        }
    }
}



