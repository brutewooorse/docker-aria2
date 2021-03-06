FROM python:3.9-slim-buster
MAINTAINER Brute Woorse  brutewoorse@gmail.com

# Installing mega sdk python binding 

ENV MEGA_SDK_VERSION '3.8.0'
RUN apt-get -qq update && apt-get -qq install -y git g++ gcc autopoint gettext autoconf automake \
    m4 libtool qt4-qmake make libqt4-dev libcurl4-openssl-dev \
    libcrypto++-dev libsqlite3-dev libc-ares-dev \
    libsodium-dev autopoint gettext libnautilus-extension-dev \
    libssl-dev libfreeimage-dev swig && \
    rm -rf /var/lib/apt/lists/* && \ 
    git clone https://github.com/meganz/sdk.git sdk && cd sdk &&\
    git checkout v$MEGA_SDK_VERSION && ./autogen.sh && \
    ./configure --disable-silent-rules --enable-python --disable-examples && \
    make -j$(nproc --all) && cd bindings/python/ && \
    python3 setup.py bdist_wheel && cd dist/ && \
    pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl && \
   #Clean up removing all build packages and dev libraries, remove unused dependencies and temp files	
	apt-get purge -yqq m4 g++ gcc automake libcurl4-openssl-dev make qt4-qmakec libsodium-dev libcrypto++ libfreeimage swig libnautilus-extension-dev  build-essential git pkg-config libssl-dev bzip2 wget zlib1g-dev libswscale-dev autopoint python gettext nettle-dev libgmp-dev libssh2-1-dev libgnutls28-dev libc-ares-dev libxml2-dev libsqlite3-dev autoconf libtool libcppunit-dev && \
	#Install shared libraries only 
	echo "APT::Install-Recommends \"0\";" >> /etc/apt/apt.conf.d/01norecommend && \
	echo "APT::Install-Suggests \"0\";" >> /etc/apt/apt.conf.d/01norecommend && \
	apt-get update && apt-get install -y libxml2 libsqlite3-0 libssh2-1 libc-ares2 && \
	apt-get autoremove --purge -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get -qq update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/* && \
    apt-add-repository non-free && \
    apt-get -qq update && \
    apt-get -qq install -y p7zip-full p7zip-rar curl pv jq ffmpeg locales python3-lxml && \
    apt-get purge -y software-properties-common

