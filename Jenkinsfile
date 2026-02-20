pipeline {
    agent any
    environment {
        IMAGE_NAME = 'jenkins-with-docker'
        IMAGE_TAG = 'latest'
        WORKSPACE_DIR = '/workspace/docker'
    }
    stages {
        stage('Clone Source') {
            steps {
                dir("${WORKSPACE_DIR}") {
                    deleteDir() // wipe old files
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
                echo "Skipping push since repo is public; add Docker Hub creds if needed"
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
