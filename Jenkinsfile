pipeline {
    agent any
    environment {
        // Docker image info
        IMAGE_NAME = 'jenkins-with-docker'
        IMAGE_TAG = 'latest'
        
        // Jenkins credentials ID for Docker Hub (create in Jenkins → Credentials)
        DOCKER_HUB_CREDENTIALS = 'docker-hub-creds'
        
        // Path inside container where your repo lives
        WORKSPACE_DIR = '/workspace/docker'
    }
    stages {
        stage('Clone Source') {
            steps {
                dir("${WORKSPACE_DIR}") {
                    git branch: 'main', url: 'https://github.com/theparasuraman/docker.git'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir("${WORKSPACE_DIR}") {
                    sh "docker build -t $IMAGE_NAME:$IMAGE_TAG ."
                }
            }
        }

        stage('Test Container') {
            steps {
                sh "docker run --rm $IMAGE_NAME:$IMAGE_TAG echo 'Container works!'"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "$DOCKER_HUB_CREDENTIALS", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                        docker tag $IMAGE_NAME:$IMAGE_TAG \$DOCKER_USER/$IMAGE_NAME:$IMAGE_TAG
                        docker push \$DOCKER_USER/$IMAGE_NAME:$IMAGE_TAG
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                dir("${WORKSPACE_DIR}") {
                    sh 'kubectl apply -f deployment.yaml'
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up dangling Docker images..."
            sh 'docker image prune -f'
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs above for details."
        }
    }
}
