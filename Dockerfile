FROM kalilinux/kali-rolling

#https://github.com/moby/moby/issues/27988
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Update + common tools + Install Metapackages https://www.kali.org/docs/general-use/metapackages/

RUN apt-get update; apt-get install -y -q kali-linux-headless

# Default packages

RUN apt-get install -y wget curl net-tools whois netcat-traditional pciutils bmon htop tor

# Kali - Common packages

RUN apt -y install amap \
    apktool \
    arjun \
    beef-xss \
    binwalk \
    cri-tools \
    dex2jar \
    dirb \
    exploitdb \
    kali-tools-top10 \
    kubernetes-helm \
    lsof \
    ltrace \
    man-db \
    nikto \
    set \
    steghide \
    strace \
    theharvester \
    trufflehog \
    uniscan \
    wapiti \
    whatmask \
    wpscan \
    xsser \
    yara

#Sets WORKDIR to /usr

WORKDIR /usr

# XSS-RECON

RUN git clone https://github.com/Ak-wa/XSSRecon; 

# Install language dependencies

RUN apt -y install python3-pip npm nodejs golang

# PyEnv
RUN apt install -y build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl

RUN curl https://pyenv.run | bash

# Set-up necessary Env vars for PyEnv
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN pyenv install -v 3.7.16; pyenv install -v 3.8.15

# GitHub Additional Tools

# Blackbird
# for usage: blackbird/
# python blackbird.py
RUN git clone https://github.com/p1ngul1n0/blackbird && cd blackbird && pyenv local 3.7.16 && pip install -r requirements.txt && cd ../

# Maigret
# for usage: cd maigret/
# ./maigret.py
RUN git clone https://github.com/soxoj/maigret.git && cd maigret && pyenv local 3.8.15 && pip3 install -r requirements.txt && cd ../

# Sherlock
# for usage cd sherlock/
# python3 sherlock --help
RUN git clone https://github.com/sherlock-project/sherlock.git && cd sherlock && pyenv local 3.8.15  && python3 -m pip install -r requirements.txt &&  cd ../

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils \
    && apt-get install -y --no-install-recommends amass awscli curl dnsutils \
    dotdotpwn file finger ffuf gobuster git hydra impacket-scripts john less locate \
    lsof man-db netcat-traditional nikto nmap proxychains4 python3 python3-pip python3-setuptools \
    python3-wheel unzip ssh wget smbclient smbmap socat ssh-client sslscan sqlmap telnet tmux unzip whatweb vim zip \
    # Slim down layer size
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    # Remove apt-get cache from the layer to reduce container size
    && rm -rf /var/lib/apt/lists/*
RUN sudo apt-get install -y curl ffmpeg git locales nano python3-pip screen ssh unzip wget  
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
RUN curl -sL https://deb.nodesource.com/setup_21.x | bash -
RUN sudo apt-get install -y nodejs
ENV LANG en_US.utf8
ARG NGROK_TOKEN
ENV NGROK_TOKEN=${NGROK_TOKEN}
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip
RUN unzip ngrok.zip
RUN echo "./ngrok config add-authtoken ${NGROK_TOKEN} &&" >>/start
RUN echo "./ngrok tcp --region ap 22 &>/dev/null &" >>/start
RUN mkdir /run/sshd
RUN echo '/usr/sbin/sshd -D' >>/start
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config 
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo root:kaal|chpasswd
RUN service ssh start
RUN chmod 755 /start
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306
CMD  /start
