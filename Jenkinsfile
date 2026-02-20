pipeline {
    agent any

    environment {
        IMAGE_NAME = "theparasuraman/nginx-ubuntu"
    }

    stages {

        stage('Clone Source') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/theparasuraman/docker.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:latest .'
            }
        }

        stage('Test Container') {
            steps {
                sh '''
                docker run -d --name test-nginx -p 8090:80 $IMAGE_NAME:latest
                sleep 5
                curl --fail http://localhost:8090
                docker stop test-nginx
                docker rm test-nginx
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push $IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl apply -f deployment.yaml
                '''
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f || true'
        }
        success {
            echo 'Pipeline executed successfully 🚀'
        }
        failure {
            echo 'Pipeline failed ❌'
        }
    }
}
