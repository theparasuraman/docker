pipeline {
    agent any

    environment {
        DOCKER_REPO = 'theparasuraman'  
        IMAGE_NAME  = 'jenkins-with-docker'
        IMAGE_TAG   = "${BUILD_NUMBER}" 
    }

    stages {

        stage('Clone Source') {
            steps {
                deleteDir()
                git branch: 'main', url: 'https://github.com/theparasuraman/docker.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t $DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG .
                    docker tag $DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG $DOCKER_REPO/$IMAGE_NAME:latest
                """
            }
        }

        stage('Test Container') {
            steps {
                sh "docker run --rm $DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG echo 'Container works!'"
            }
        }


stage('Deploy to Kubernetes') {
    steps {
        sh """
            sed -i 's|image:.*|image: $DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG|' deployment.yaml
            kubectl apply -f deployment.yaml
        """
    }
}

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG
                        docker push $DOCKER_REPO/$IMAGE_NAME:latest
                        docker logout
                    """
                }
            }
        }
    }


    post {
        always {
            sh 'docker image prune -f'
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs above."
        }
    }
}
