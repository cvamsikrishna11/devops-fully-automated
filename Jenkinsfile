def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger',
]

pipeline {
    agent any

    environment {
        WORKSPACE = "${env.WORKSPACE}"
    }

    tools {
        maven 'localMaven'
    }

    stages {
        stage('Git checkout') {
            steps {                
                echo 'Cloning the application code...'
                git branch: 'main', url: 'https://github.com/cvamsikrishna11/devops-fully-automated.git'
            }
        }

        stage('Checkstyle Code Analysis') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Checkstyle analysis completed successfully.'
                }
                failure {
                    echo 'Checkstyle violations found.'
                }
            }
        }

        stage('Clean and Compile') {
            steps {
                sh 'mvn -U clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
                junit '**/target/surefire-reports/*.xml'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'            
            }
            post {
                success {
                    echo 'Package completed. Archiving artifacts...'
                    archiveArtifacts artifacts: '**/target/*.war', followSymlinks: false
                }
                failure {
                    echo 'Package failed. Skipping artifact archival.'
                }
            }
        }

        stage('SonarQube scanning') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                        sh """
                        mvn sonar:sonar \
                        -Dsonar.projectKey=maven \
                        -Dsonar.host.url=http://172.31.82.140:9000 \
                        -Dsonar.login=$SONAR_TOKEN
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                waitForQualityGate abortPipeline: true
            }
        }

        stage('Upload artifact to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USER_NAME')]) {
                    sh "sed -i \"s/.*<username><\\/username>/<username>$USER_NAME<\\/username>/g\" ${WORKSPACE}/nexus-setup/settings.xml"
                    sh "sed -i \"s/.*<password><\\/password>/<password>$PASSWORD<\\/password>/g\" ${WORKSPACE}/nexus-setup/settings.xml"
                    sh 'cp ${WORKSPACE}/nexus-setup/settings.xml /var/lib/jenkins/.m2'
                    sh 'mvn deploy -DskipTests'
                }
            }
            post {
                success {
                    echo 'Arfiacts has been backed up onto Nexus..!'
                }
                failure {
                    echo 'Artifact upload failed hence removing the settings.xml file which might cause issues on the check-style'
                    sh 'sudo rm -f /var/lib/jenkins/.m2/settings.xml'
                }
            }
        }

        stage('Deploy to DEV env') {
            environment {
                HOSTS = 'dev'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'ansible-deploy-server-credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USER_NAME')]) {
                    sh "ansible-playbook -i ${WORKSPACE}/ansible-setup/aws_ec2.yaml ${WORKSPACE}/deploy.yaml --extra-vars \"ansible_user=$USER_NAME ansible_password=$PASSWORD hosts=tag_Environment_$HOSTS workspace_path=$WORKSPACE\""
                }
            }
        }

        stage('Deploy to STAGE env') {
            environment {
                HOSTS = 'stage'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'ansible-deploy-server-credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USER_NAME')]) {
                    sh "ansible-playbook -i ${WORKSPACE}/ansible-setup/aws_ec2.yaml ${WORKSPACE}/deploy.yaml --extra-vars \"ansible_user=$USER_NAME ansible_password=$PASSWORD hosts=tag_Environment_$HOSTS workspace_path=$WORKSPACE\""
                }
            }
        }

        stage('Approval') {
            steps {
                input('Do you want to proceed?')
            }
        }

        stage('Deploy to PROD env') {
            environment {
                HOSTS = 'prod'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'ansible-deploy-server-credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USER_NAME')]) {
                    sh "ansible-playbook -i ${WORKSPACE}/ansible-setup/aws_ec2.yaml ${WORKSPACE}/deploy.yaml --extra-vars \"ansible_user=$USER_NAME ansible_password=$PASSWORD hosts=tag_Environment_$HOSTS workspace_path=$WORKSPACE\""
                }
            }
        }
    }

    post {
        always {
            echo 'I will always say Hello again!'
            slackSend channel: '#team-devops', color: COLOR_MAP[currentBuild.currentResult], message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
    }
}
