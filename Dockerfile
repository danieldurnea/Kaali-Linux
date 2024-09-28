FROM kalilinux/kali-rolling:latest

RUN DEBIAN_FRONTEND=noninteractive 
  

LABEL maintainer="admin@csalab.id"
RUN sed -i "s/http.kali.org/mirrors.ocf.berkeley.edu/g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install \
    sudo \
    openssh-server \
    python2 \
    unzip \
    wget 
ARG NGROK_TOKEN
ARG Password
ENV Password=${Password}
ENV NGROK_TOKEN=${NGROK_TOKEN}

# Download and unzip ngrok
RUN wget -O ngrok.zip  https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip > /dev/null 2>&1
RUN unzip ngrok.zip

# Create shell script
RUN echo "./ngrok config add-authtoken ${NGROK_TOKEN} &&" >>/kali.sh
RUN echo "./ngrok tcp 22 &>/dev/null &" >>/kali.sh


# Create directory for SSH daemon's runtime files

RUN service ssh start
RUN chmod 755 kali.sh

# Expose port


EXPOSE 22/tcp
CMD ["sleep", "infinity"
