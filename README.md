# Jenkins CI/CD Pipeline Project Architecture (Java Web Application)
![CompleteCICDProject!](https://lucid.app/publicSegments/view/a6ef3233-7dda-483a-a662-d8ec90395ba3/image.png)

# Jenkins Complete CI/CD Pipeline Environment Setup 

## CICD Applications setup
1) ###### GitHub setup
    Import GitHub Repository by using the existing repo "devops-fully-automated" (https://github.com/cvamsikrishna11/devops-fully-automated)     
    - Go to GitHub (github.com)
    - Login to your GitHub Account
    - **Import repository "devops-fully-automated" (https://github.com/cvamsikrishna11/devops-fully-automated) & name it "devops-fully-automated"**
    - Clone your newly created repo to your local

2) ###### Jenkins/Maven/Ansible
    - Create an **Amazon Linux 2 VM** instance and call it "jenkins-maven-ansible"
    - Instance type: t2.medium
    - Security Group (Open): 8080, 9100 and 22 to 0.0.0.0/0
    - Key pair: Select or create a new keypair
    - **Attach Jenkins server with IAM role having "AdministratorAccess"**
    - User data (Copy the following user data): https://github.com/cvamsikrishna11/devops-fully-automated/blob/installations/jenkins-maven-ansible-setup.sh
    - Launch Instance
    - After launching this Jenkins server, attach a tag as **Key=Application, value=jenkins**

3) ###### SonarQube
    - Create an Create an **Ubuntu 20.04** VM instance and call it "SonarQube"
    - Instance type: t2.medium
    - Security Group (Open): 9000, 9100 and 22 to 0.0.0.0/0
    - Key pair: Select or create a new keypair
    - User data (Copy the following user data): https://github.com/cvamsikrishna11/devops-fully-automated/blob/installations/sonarqube-setup.sh
    - Launch Instance

4) ###### Nexus
    - Create an **Amazon Linux 2** VM instance and call it "Nexus"
    - Instance type: t2.medium
    - Security Group (Open): 8081, 9100 and 22 to 0.0.0.0/0
    - Key pair: Select or create a new keypair
    - User data (Copy the following user data): https://github.com/cvamsikrishna11/devops-fully-automated/blob/installations/nexus-setup.sh
    - Launch Instance

5) ###### EC2 (Dev/Stage/Prod)
    - Create 6 **Amazon Linux 2** VM instances
    - Instance type: t2.micro
    - Security Group (Open): 8080, 9100 and 22 to 0.0.0.0/0
    - Key pair: Select or create a new keypair
    - User data (Copy the following user data): https://github.com/cvamsikrishna11/devops-fully-automated/blob/installations/deployment-servers-setup.sh
    - Launch Instance
    - After launching this Jenkins servers, attach a tag as **Key=Environment, value=dev/stage/prod** ( out of 6, each 2 instances could be tagges as one env)

6) ###### Prometheus
    - Create Amazon Linux 2 VM instance and call it "Prometheus"
    - Instance type: t2.micro
    - Security Group (Open): 9090 and 22 to 0.0.0.0/0
    - Key pair: Select or create a new keypair
    - **Attach Jenkins server with IAM role having "AmazonEC2ReadOnlyAccess"**
    - User data (Copy the following user data): https://github.com/cvamsikrishna11/devops-fully-automated/blob/installations/prometheus-setup.sh
    - Launch Instance

7) ###### Grafana
    - Create an **Ubuntu 20.04** VM instance and call it "Grafana"
    - Instance type: t2.micro
    - Security Group (Open): 3000 and 22 to 0.0.0.0/0
    - Key pair: Select or create a new keypair
    - User data (Copy the following user data): https://github.com/cvamsikrishna11/devops-fully-automated/blob/installations/grafana-setup.sh
    - Launch Instance

8) ###### Slack 
    - **Join the slack channel https://join.slack.com/t/slack-wcl4742/shared_invite/zt-1kid01o3n-W47OUTHBd2ZZpSzGnow1Wg**
    - **Join into the channel "#team-devops"**

### Jenkins setup
1) #### Access Jenkins
    Copy your Jenkins Public IP Address and paste on the browser = ExternalIP:8080
    - Login to your Jenkins instance using your Shell (GitBash or your Mac Terminal)
    - Copy the Path from the Jenkins UI to get the Administrator Password
        - Run: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
        - Copy the password and login to Jenkins
    - Plugins: Choose Install Suggested Plugings 
    - Provide 
        - Username: **admin**
        - Password: **admin**
        - Name and Email can also be admin. You can use `admin` all, as its a poc.
    - Continue and Start using Jenkins

2)  #### Plugin installations:
    - Click on "Manage Jenkins"
    - Click on "Plugin Manager"
    - Click "Available"
    - Search and Install the following Plugings "Install Without Restart"
        - **SonnarQube Scanner**
        - **Prometheus metrics**
        - **CloudBees Disk Usage Simple**
        - **Slack Notification**
    - Once all plugins are installed, select **Restart Jenkins when installation is complete and no jobs are running**


3)  #### Pipeline creation
    - Click on **New Item**
    - Enter an item name: **app-cicd-pipeline** & select the category as **Pipeline**
    - Now scroll-down and in the Pipeline section --> Definition --> Select Pipeline script from SCM
    - SCM: **Git**
    - Repositories
        - Repository URL: FILL YOUR OWN REPO URL (that we created by importing in the first step)
        - Branch Specifier (blank for 'any'): */main
        - Script Path: Jenkinsfile
    - Save


4)  #### Global tools configuration:
    - Click on Manage Jenkins --> Global Tool Configuration
    - **JDK** --> Add JDK --> Make sure **Install automatically** is enabled --> Extract *.zip/*.tar.gz --> Fill the below values
        * Name: **localJdk**
        * Download URL for binary archive: **https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz**
        * Subdirectory of extracted archive: **jdk-11.0.1**
    - **Maven** --> Add Maven --> Make sure **Install automatically** is enabled --> Install from Apache --> Fill the below values
        * Name: **localMaven**
        * Version: Keep the default version as it is 

    
5)  #### Configure system:
    - Click on Manage Jenkins --> Global Tool Configuration

        1)  - Go to section SonarQube servers --> **Add SonarQube **
            - Name: **SonarQube**
            - Server URL: http://REPLACE-WITH-SONARQUBE-SERVER-PRIVATE-IP:9000          (replace SonarQube privat IP here)

        2)  - Go to section Prometheus
            - Collecting metrics period in seconds: **120**

        3)  - Go to section Slack
            - Workspace: **devops-fully-automated**
            - Credentials --> Add --> kind (Secret text)
            - Secret: **3jrfd3GjdMac0dgcxJwcOgQU**
            - ID: **slack-token**
            - Description: **slack-token**           

### SonarQube setup

Copy your Jenkins Public IP Address and paste on the browser = ExternalIP:9000
    
1)  #### Token generation:
    - Login to your SonarQube server with the credentials username: **admin** & password: **admin**
    - Click on profile --> My Account --> Security --> Tokens
    - Generate Tokens: **jenkins-token**
    - Click on **Generate**
    - **Note: Copy the token and save it as a backup somewhere**
    - Now access jenkins --> Manage jenkins --> Manage Credentials
    - Create a new secret by clicking on --> global drop-down --> Add credentials 
    - Kind: Secret text
    - Secret: Fill the secret token value that we have created on the SonarQube server
    - ID: sonarqube-token
    - Description: sonarqube-token
    - Click on Create

2)  #### Jenkins webhook in SonarQube:
    - Login into SonarQube
    - Go to Administration --> Configuration --> Webhooks --> Click on Create
    - Name: Jenkins-Webhook
    - URL: http://REPLACE-WITH-JENKINS-PRIVATE-IP:8080/sonarqube-webhook/           (replace SonarQube privat IP here)
    - Click on Create

     


9) Open a New Tab on your browser for Grafana also if you've not done so already. 
    - Copy your Grafana Instance Public IP and put on the browser with port 3000 e.g "GrafanaPublic:3000"
    - Once the UI Opens pass the following username and password
        - Username: **admin**
        - Password: **admin**
        - New Username: **admin**
        - New Password: **admin**
        - Save and Continue
    - Once you get into Grafana, follow the below steps to Import a Dashboard into Grafana to visualize your Infrastructure/App Metrics
        - Click on "Configuration/Settings" on your left
        - Click on "Data Sources"
        - Click on "Add Data Source"
        - Select Prometheus
        - Underneath HTTP URL: http://PrometheusPrivateIPaddress:9090
        - Click on "SAVE and TEST"
    - Navigate to "Create" on your left (the `+` sign)
        - Click on "Import"
        - Copy the following link: https://grafana.com/grafana/dashboards/1860
        - Paste the above link where you have "Import Via Grafana.com"
        - Click on Load (The one right beside the link you just pasted)
        - Scrol down to "Prometheus" and select the "Data Source" you defined ealier which is "Prometheus"
        - CLICK on "Import"
    - Refresh your Grafana Dashbaord 
        - Click on the "Drop Down" for "Host" and select any of the "Instances(IP)"

10) Update Your Jenkins file with your Slack Channel Name
    - Go back to your local, open your "Jenkins-CICD-Project" repo/folder/directory on VSCODE
    - Open your "Jenkinsfile"
    - Update the slack channel name on line "97"
    - Change name from "jenkins-cicd-pipeline-alerts" to yours
    - Add the changes to git, commit and push to GitHub
    - Confirm the changes reflects on GitHub



13) Confirm and make test your installations/setups  