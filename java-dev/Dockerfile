FROM phusion/baseimage:focal-1.0.0
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Chicago

RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates gnupg software-properties-common wget bash-completion curl openssh-server sudo

ARG USER_NAME=ubuntu
ARG USER_UID

RUN useradd -b /home -m -s /bin/bash -u ${USER_UID} ${USER_NAME} && \
    usermod -p '*' ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
EXPOSE 22

COPY ./id_rsa.pub /tmp
RUN sudo -u ${USER_NAME} mkdir -p /home/${USER_NAME}/.ssh && \
    sudo -u ${USER_NAME} touch /home/${USER_NAME}/.ssh/authorized_keys && \
    cat /tmp/id_rsa.pub >> /home/${USER_NAME}/.ssh/authorized_keys && \
    rm /tmp/id_rsa.pub

ARG JDK_DEB_URL
RUN apt-get install java-common && \
    wget ${JDK_DEB_URL} -P /tmp/ && \
    dpkg --install /tmp/*.deb && \
    rm /tmp/*.deb

ARG MAVEN_URL
RUN wget -qO- ${MAVEN_URL} | tar xzf - -C /opt

ARG JAVA_HOME
RUN echo "export JAVA_HOME=${JAVA_HOME}" >> /home/${USER_NAME}/.profile
RUN echo "export PATH=\$PATH:/opt/apache-maven-3.8.1/bin" >> /home/${USER_NAME}/.profile

RUN apt -y install build-essential htop nano git gdb tmux python3-pip && \
    apt -y install less libxext6 libxrender1 libxtst6 libfreetype6 libxi6 && \
    apt -y clean

ENV PATH=/home/${USER_NAME}/.local/bin:$PATH
RUN echo "export PATH=\"${PATH}\"" | tee -a /home/${USER_NAME}/.profile

RUN /sbin/setuser ${USER_NAME} python3 -m pip install -U pip && \
    /sbin/setuser ${USER_NAME} python3 -m pip install projector-installer --user
ENV PROJECTOR_BIN="/home/${USER_NAME}/.local/bin/projector"

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
RUN echo "export PROJECTOR_BIN=\"${PROJECTOR_BIN}\"" | tee -a /home/${USER_NAME}/.profile
RUN echo "export LC_ALL=\"${LC_ALL}\"" | tee -a /home/${USER_NAME}/.profile && \
    echo "export LANG=\"${LANG}\"" | tee -a /home/${USER_NAME}/.profile

RUN /sbin/setuser ${USER_NAME} ${PROJECTOR_BIN} --accept-license \
    ide autoinstall --config-name idea --port 8080 \
    --ide-name "IntelliJ IDEA Community Edition 2020.3.4"
EXPOSE 8080

RUN sudo mkdir -p /etc/service/projector && \
    echo "#!/bin/sh\nexec /sbin/setuser ${USER_NAME} ${PROJECTOR_BIN} config run" | sudo tee -a /etc/service/projector/run && \
    sudo chmod +x /etc/service/projector/run

RUN echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf

COPY ./setup-github-token.sh /opt
RUN mkdir /etc/service/github-token && \
    echo "#!/bin/sh\nexec /sbin/setuser ${USER_NAME} /opt/setup-github-token.sh" > /etc/service/github-token/run && \
    chmod +x /etc/service/github-token/run
