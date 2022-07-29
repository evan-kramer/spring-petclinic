# 1 Use provisioning tool to set up Ubuntu VM/container with Jenkins, Blue Ocean and SonarQube plugins
Because of the challenges I had in automated provisioning, I also did some manual configurations, per Palash's suggestion.

# 1.1 Create bridge network to run containers
docker network create 17646-assignment1

# 1.2 Create Dockerfiles and build/run images. Alternatively, use docker-compose.yml
Run Docker-in-Docker, Jenkins, and SonarQube containers

# 1.2.1 Run Docker-in-Docker
docker run --name jenkins-docker --rm --detach \
  --privileged --network 17646-assignment1 --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 --publish 3000:3000 \
  docker:dind --storage-driver overlay2 

# 1.2.2 Create Dockerfile for running Jenkins and Blue Ocean
FROM jenkins/jenkins:2.346.2-jdk11
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean:1.25.5 docker-workflow:1.28"

# 1.2.3 Build Docker image for Jenkins and Blue Ocean
docker build -f Assignments/1/test/jenkins/Dockerfile -t jenkins-17646-assignment1 .

# 1.2.4 Run Jenkins and Blue Ocean container
docker run --name jenkins-17646-assignment1 --detach \
  --network 17646-assignment1 --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 --publish 8081:8081 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  --volume "$HOME":/home \
  --restart=on-failure \
  --env JAVA_OPTS="-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true" \
  jenkins-17646-assignment1

# 1.2.5 Configure Jenkins and Blue Ocean
Point web browser to http://localhost:8080.
Enter password (from log file) to unlock Jenkins.
Enter credentials to create first admin user.
Click on "Install suggested plugins", which installs Blue Ocean.
Navigate to Manage Jenkins > Global Tool Configuration and set up default versions of Java and Maven to use later in the Pipeline.

# 1.3.1 Run SonarQube container and install 
docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  -p 9000:9000 \
  --network 17646-assignment1 --platform linux/amd64 sonarqube:latest

# 1.3.2 Install SonarQube plugin for Jenkins
From the Jenkins service, click on "Manage Plugins"
Select the "Available" tab
Search for SonarQube; click "SonarQube Scanner"
Click "Install without restart"
Click "Restart Jenkins when no jobs are running"

# 1.3.3 Integrate SonarQube and Jenkins
Log into SonarQube at http://localhost:9000 using "admin" as both the username and password.
Change password when prompted.
Click on user icon > My Account > Security.
Generate token (type=Global Analysis Token) to be able to use to connect to Jenkins.
Back at the Jenkins Dashboard, navigate to Credentials > System from the left navigation.
Click the Global credentials (unrestricted) link in the System table.
Click Add credentials in the left navigation and add the following information:
- Kind: Secret Text
- Scope: Global
- Secret: Generate a token at User > My Account > Security in SonarQube, and copy and paste it here.
Set up SonarQube server in Jenkins (navigate to Manage Jenkins > Configure System > SonarQube servers. Provide a name, set server=http://sonarqube:9000, and provide the token previously created to authenticate.
Set up SonarQube Scanner build in Jenkins (Manage Jenkins > Global Tool Configuration > SonarQube Scanner (just give it a name and install automatically))
Save and apply changes.


# 2 Use SonarQube to do a static analysis of petclinic open source app (https://github.com/spring-projects/spring-petclinic)

# 2.1 Fork and clone spring-petclinic repository
Navigate to https://github.com/spring-projects/spring-petclinic.
Click on "Fork" to fork the repository.
Clone the repository into the appropriate local directory.

# 2.2 Create pipeline
From the Jenkins home page, add a new pipeline.
Give it a name, then scroll to the bottom to indicate that the Pipeline will use Git with SCM, point it to the GitHub repo you just cloned, and provide credentials to authenticate with GitHub.
Ensure that the pipeline references the SonarQube builder and global tools you previously set up.
Point the pipeline to the path of the Jenkinsfile you created (or will create).
Ensure the Jenkinsfile outlines the agent, tools (i.e., the ones you configured in 1.3.3), any options, the stages and corresponding steps, and any post-run actions.

# 2.3 Give permissions in SonarQube to run analyses
Create a project in SonarQube and ensure you use the same token as before. Alternatively, you can generate a new token and use it as an environment variable when calling the SonarQube scanner.
Select the appropriate permissions and user groups for that key to be able to run static analyses.
Update the Jenkinsfile with environment and steps for the SonarQube scanner stage.

# 2.4 Set up Jenkinsfile for SonarQube analysis
Add a stage to the Jenkinsfile for the SonarQube analysis. 
Make sure to add an environment block that references the SonarQube scanner that you set up in 1.3.3.
Wrap the steps of this stage in a `withSonarQubeEnv` block that refers to the SonarQube scanner.

# 2.5 Review SonarQube scanner analysis
Navigate to the SonarQube application (http://localhost:9000) and review the output of the static code analysis.
This output includes an overview of the code quality, all issues the analysis flagged, any security red flags, an interface for visualizing data, the code itself, and history about activity in the repository.


# 3 Visualize build process with Blue Ocean (either on same VM/container or separate)
Navigate to Blue Ocean.
Click Run.
Click OPEN to view results.
Alternatively, you can set up a webhook that automatically initiates the Jenkins pipeline you configured whenever new commits are pushed to the repository.


# 4 Use Jenkins to build petclininc.jar
Add a new stage to the Jenkinsfile. 
Ensure this stage has a `mvn package` call that builds the `.jar` files that we will eventually run as the backend of the application.
Given that you are forking an existing repository, you can use existing tests written for the application. 


# 5 Execute petclinic.jar and take a screenshot of the welcome screen
In the final delivery stage, the Jenkinsfile should package and run `.jar` files. 
Specify the `-Dserver.port=XXXX (e.g., 8081) to specify the port on which to host the petclinic application.
Ensure that this port is reachable by the container (i.e., the `--publish` option should publish/expose the appropriate port(s)).


# 6 Copy petclinic.jar to host machine for future reference
You can use `docker cp <container_id>:</path/to/spring-petclinic> </local/path/to/spring-petclinic> to save a copy of the petclinic.jar file.
Note that this will appear in the `target/` directory where you specified that Maven should build/package.


# From Piazza discussion: Guidance on screenshots:
Key screens include 
- Any manual configuration that you’ve performed and result of said changes. 
- These should include Jenkins build stages, Jenkins setup, sonarqube setup and authentication, scanning results on sonarqube, and the pet clinic screen.
- Any other items that might add value to your write ups can be added as screenshots. If in doubt, always add more screenshots.

# References
https://phoenixnap.com/kb/install-jenkins-ubuntu: Tutorial for installing Jenkins and dependencies
https://www.vultr.com/docs/install-sonarqube-on-ubuntu-20-04-lts/: Tutorial for installing and configuring SonarQube
https://www.how2shout.com/linux/install-sonarqube-on-ubuntu-20-04-18-04-server/: Another tutorial for installing SonarQube
https://www.jenkins.io/doc/tutorials/build-a-java-app-with-maven/: Useful for running Java program via Jenkins
https://funnelgarden.com/sonarqube-jenkins-docker/: Tutorial for integrating Jenkins and SonarQube in a containerized environment
https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code: Automate Jenkins setup
https://medium.com/@rosaniline/setup-sonarqube-with-jenkins-declarative-pipeline-75bccdc9075f: Helpful tutorial for setting up SonarQube