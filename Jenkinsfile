pipeline {
  agent any
  stages {
   stage ('Initialize') {
            steps {
                sh '''
                    M2_HOME=/opt/apache-maven-3.8.3
                    M2=/opt/apache-maven-3.8.3/bin
                    PATH=$PATH:$HOME/bin/:$JAVA_HOME:$M2:$M2_HOME
                    export PATH
                    echo "PATH = ${PATH}"
                    echo "M2_HOME = ${M2_HOME}"
                    whoami
                '''
            }
        }
    stage('cleaning package') {
      steps {
        sh 'mvn clean install package'
      }
    }   
       
    stage('SonarQube analysis') {
      withSonarQubeEnv(credentialsId: '8c1d4173a23c20f7e3805402dce37a564a10064e', installationName: 'sonar') { // You can override the credential to be used
       steps {
        sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.6.0.1398:sonar'
    }
    }
 
    
    stage('building docker image from docker file by tagging') {
      steps {
        sh 'docker build -t mukhesh/pipeline:$BUILD_NUMBER .'
      }   
    }
   
    stage('logging into docker hub') {
      steps {
        withCredentials([string(credentialsId: 'docker-pwd', variable: 'dockerHubPwd')]) {
          sh 'docker login -u "mukhesh" -p "${dockerHubPwd}"'
      }
    }
      
    }
    stage('pushing docker image to the docker hub with build number') {
      steps {
        sh 'docker push mukhesh/pipeline:$BUILD_NUMBER'
      }   
    }
     stage('deploying the docker image into EC2 instance and run the container') {
      steps {
        sh 'ansible-playbook deploy.yml --extra-vars="buildNumber=$BUILD_NUMBER"'
      }   
    }  
  }
  post {
    failure {
        mail to: 'mukheshgoud40@gmail.com',
             subject: "Failed Pipeline: ${BUILD_NUMBER}",
             body: "Something is wrong with ${env.BUILD_URL}"
    }
     success {
        mail to: 'mukheshgoud40@gmail.com',
             subject: "successful Pipeline:  ${env.BUILD_NUMBER}",
             body: "Your pipeline is success ${env.BUILD_URL}"
    }
}
}
