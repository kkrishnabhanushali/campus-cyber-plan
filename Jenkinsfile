pipeline {
  agent any
  environment {
    IMAGE = "kkrish123/campus-cyber-plan"
    TAG   = "${env.BUILD_NUMBER}"
  }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Test')     { steps { sh 'sh test.sh' } }
    stage('SonarQube Scan') {
      steps {
        withSonarQubeEnv('sonarqube') {
          sh 'sonar-scanner'
        }
      }
    }
    stage('Trivy FS Scan') {
      steps { sh 'trivy fs --severity HIGH,CRITICAL --format table -o trivy-fs.txt . || true' }
    }
    stage('Docker Build') { steps { sh 'docker build -t $IMAGE:$TAG -t $IMAGE:latest .' } }
    stage('Trivy Image Scan') {
      steps { sh 'trivy image --severity HIGH,CRITICAL -o trivy-image.txt $IMAGE:$TAG || true' }
    }
    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'U', passwordVariable: 'P')]) {
          sh 'echo $P | docker login -u $U --password-stdin && docker push $IMAGE:$TAG && docker push $IMAGE:latest'
        }
      }
    }
    stage('Deploy (local Docker)') {
      steps { sh 'docker rm -f campus-app || true; docker run -d --name campus-app -p 8081:8080 $IMAGE:$TAG' }
    }
  }
  post { always { archiveArtifacts artifacts: 'trivy-*.txt', allowEmptyArchive: true } }
}
