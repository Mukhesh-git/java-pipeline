pipeline {
  agent any
   tools {
     maven 'maven'
   }
  stages {
      stage ('Initialize') {
        steps {
           sh '''
              M2_HOME=/opt/maven
              M2=/opt/maven/bin
              PATH=$PATH:$HOME/bin/:$JAVA_HOME:$M2:$M2_HOME
              export PATH
              echo "PATH = ${PATH}"
              echo "M2_HOME = ${M2_HOME}"
              whoami
              '''
             }
         }
     stage('Build maven') {
       steps {
        sh 'mvn clean install package'
       }
     }
    stage('Sonar analaysis') {
      steps {
        sh '''
            mvn sonar:sonar \
              -Dsonar.host.url=http://sonarqube.mukesh.website \
              -Dsonar.login=aecbdd032173cbfdb65c14ecdca8dd47a6654eb3
           '''   
      }
    }
 // stage('Push artifact to s3') {
//    steps {
//      sh 'aws s3 cp webapp/target/webapp.war s3://vaishu-s'
//      }
//    }
//   stage('Deploy to tomcat') {
//     steps {
//        sh 'ansible-playbook deploy_new.yml'
//      }
//    }  
    
  stage('building docker image from docker file by tagging') {
      steps {
        sh 'docker build -t mukhesh/pipeline:$BUILD_NUMBER .'
      }   
    }
 
  stage('logging into docker hub') {
      steps {
        withCredentials([string(credentialsId: 'docker-pwd', variable: 'dockerHubPwd')]) {
          sh "docker login -u mukhesh -p ${dockerHubPwd}"
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
     always {
       emailext to: 'mukheshgoud40@gmail.com',
       attachLog: true, body: "Dear team pipeline is ${currentBuild.result} please check ${BUILD_URL} or PFA build log", compressLog: false,
       subject: "Jenkins Build Notification: ${JOB_NAME}-Build# ${BUILD_NUMBER} ${currentBuild.result}"
    }
 }
}
