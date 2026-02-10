ARG DISTRO=trixie
FROM debian:${DISTRO}

ARG EXIM_VERSION
ARG ARCH
ARG CPUS

COPY ./DEBIAN /DEBIAN
RUN mkdir -p /st-exim/opt/exim4

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install \
    apt-utils \
    build-essential \
    ca-certificates \
    exim4-daemon-heavy \
    git \
    libgcrypt20-dev \
    libnsl-dev \
    libgdbm-dev \
    libgnutls-dane0 \
    libgnutls-openssl27 \
    libgnutls28-dev \
    libgsasl-dev \
    libldap-dev \
    libmail-srs-perl \
    libmariadb-dev \
    libopendmarc-dev \
    libpam0g-dev \
    libpcre2-dev \
    libperl-dev \
    libspf2-dev \
    libsqlite3-dev \
    lintian \
    pkg-config && \
  rm -rf /var/lib/apt/lists/*

RUN useradd spamtagger --system --create-home --user-group \
  --home-dir /var/spamtagger \
  --shell /usr/sbin/nologin

RUN git clone https://github.com/exim/exim.git --depth 1
WORKDIR exim
RUN git fetch --tags && git checkout exim-${EXIM_VERSION}

WORKDIR /exim/src
RUN mkdir Local
RUN cp /DEBIAN/EDITME Local/Makefile
RUN EXIM_RELEASE_VERSION=${EXIM_VERSION} make -j${CPUS}
RUN make install

RUN mkdir -p /st-exim/opt/exim4
RUN cp -a /opt/exim4/* /st-exim/opt/exim4/
RUN cp -r /DEBIAN /st-exim/

RUN sed -i 's/__INSTVER__/'${EXIM_VERSION}+${DISTRO}'/' /st-exim/DEBIAN/control && \
  sed -i 's/__INSTSIZE__/'$(du -sk /st-exim | cut -f1)'/' /st-exim/DEBIAN/control

WORKDIR /

RUN dpkg-deb -b -Z gzip /st-exim /tmp/st-exim.deb

CMD lintian /tmp/st-exim.deb
