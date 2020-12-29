FROM jenkins/jnlp-slave:4.6-1

USER 0

RUN curl -L https://download.docker.com/linux/static/stable/x86_64/docker-19.03.14.tgz | tar xvz -C / 

RUN export KRB5CCNAME=FILE:/tmp/tgt \
&& export DEBIAN_FRONTEND=noninteractive \
&& apt-get update \
&& apt-get install -y python-pip krb5-user libkrb5-dev \
&& pip install "ansible>=2.9" "docker" "requests" "openshift" "pywinrm[kerberos]" "kerberos" "dnspython" \
&& apt-get clean all

RUN export OC_PATH=/openshit \
&& export OC_VERSION=v3.11.0 \
&& export OC_REVISION=0cbc58b \
&& export OC_FILE=openshift-origin-client-tools-$OC_VERSION-$OC_REVISION-linux-64bit \
&& export OC_TAR=$OC_FILE.tar.gz \
&& export OC_REPO=https://github.com/openshift/origin/releases/download \
&& export OC_URL=$OC_REPO/$OC_VERSION/$OC_TAR \
&& curl -L $OC_URL | tar xvz -C /tmp \
&& mv /tmp/${OC_FILE} $OC_PATH \
&& chmod -R g=u $OC_PATH \
&& chmod -R o=u $OC_PATH

USER jenkins
RUN echo $HOME
ENV NVM_DIR="/home/jenkins/.nvm"
ENV PATH=/docker:/openshit:$PATH:$NVM_DIR:/home/jenkins/.nvm/versions/node/v14.15.3/bin
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash \
&&  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install node \
&&  curl -L https://npmjs.org/install.sh | sh

USER root
ENV MAVEN_OPTS="-Dmaven.repo.local=/tmp/maven"
RUN apt-get update -y && apt-get install -y maven && apt-get clean all
RUN mvn deploy:deploy-file dependency:go-offline || /bin/true

ENV PATH=/docker:/openshit:$PATH


