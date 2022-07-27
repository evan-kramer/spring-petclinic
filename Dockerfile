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

# To run first container (docker server): 
# docker run --name jenkins-docker --detach `
#  --privileged --network 17646-assignment1 --network-alias docker `
#  --env DOCKER_TLS_CERTDIR=/certs `
#  --volume jenkins-docker-certs:/certs/client `
#  --volume jenkins-data:/var/jenkins_home `
#  --publish 3000:3000 --publish 2376:2376 `
#  docker:dind

# To run second container:
# docker build -t jenkins-17646-assignment1 .
# docker run --name 17646-assignment1 -d -p 8080:8080 -p 50000:50000 -p 8081:8081 --network 17646-assignment1 --env DOCKER_HOST=tcp://docker:2376 --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 --env JAVA_OPTS="-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true" --volume jenkins-data:/var/jenkins_home --volume jenkins-docker-certs:/certs/client:ro --restart=on-failure jenkins-17646-assignment1