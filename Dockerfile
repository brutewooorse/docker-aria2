FROM python:3.9-slim-buster
MAINTAINER Brute Woorse  brutewoorse@gmail.com

ENV GIT_BRANCH master

# Update packages in base image, avoid caching issues by combining statements, install build software and deps
RUN	apt-get update && apt-get install -y build-essential git pkg-config libssl-dev bzip2 wget zlib1g-dev libswscale-dev python gettext nettle-dev libgmp-dev libssh2-1-dev libgnutls28-dev libc-ares-dev libxml2-dev libsqlite3-dev autoconf libtool libcppunit-dev && \
	rm -rf /var/lib/apt/lists/* && \
	#Install aria2 from git, cleaning up and removing all build footprint	
	git clone https://github.com/tatsuhiro-t/aria2.git /opt/aria2 && \
	cd /opt/aria2 && \
	git checkout $GIT_BRANCH && \
	autoreconf -i && ./configure && \
	make && make install && \
	cd /opt && rm -rf /opt/aria2 && \
	#Clean up removing all build packages and dev libraries, remove unused dependencies and temp files	
	apt-get purge -yqq build-essential git pkg-config libssl-dev bzip2 wget zlib1g-dev libswscale-dev python gettext nettle-dev libgmp-dev libssh2-1-dev libgnutls28-dev libc-ares-dev libxml2-dev libsqlite3-dev autoconf libtool libcppunit-dev && \
	#Install shared libraries only 
	echo "APT::Install-Recommends \"0\";" >> /etc/apt/apt.conf.d/01norecommend && \
	echo "APT::Install-Suggests \"0\";" >> /etc/apt/apt.conf.d/01norecommend && \
	apt-get update && apt-get install -y libxml2 libsqlite3-0 libssh2-1 libc-ares2 && \
	apt-get autoremove --purge -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/usr/local/bin/aria2c","--conf-path=/config/aria2.conf"]
# Installing mega sdk python binding
RUN apt-get -qq update
RUN apt-get -qq install -y git g++ gcc autoconf automake \
    m4 libtool qt4-qmake make libqt4-dev libcurl4-openssl-dev \
    libcrypto++-dev libsqlite3-dev libc-ares-dev \
    libsodium-dev libnautilus-extension-dev \
    libssl-dev libfreeimage-dev swig
    
ENV MEGA_SDK_VERSION '3.8.0'
RUN git clone https://github.com/meganz/sdk.git sdk && cd sdk &&\
    git checkout v$MEGA_SDK_VERSION && ./autogen.sh && \
    ./configure --disable-silent-rules --enable-python --disable-examples && \
    make -j$(nproc --all) && cd bindings/python/ && \
    python3 setup.py bdist_wheel && cd dist/ && \
    pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl

