FROM debian:bookworm
ARG EXIM_VERSION=${EXIM_VERSION}
COPY ./DEBIAN /DEBIAN
RUN mkdir -p /mc-exim/opt/exim4

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install \
    apt-utils \
    build-essential \
    exim4-daemon-heavy \
    git \
    libgcrypt20-dev \
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
    pkg-config
RUN useradd mailcleaner --system --create-home --user-group --home-dir /var/mailcleaner --shell /usr/sbin/nologin
RUN git clone https://github.com/exim/exim.git --depth 1
WORKDIR exim
RUN git fetch --tags
RUN git checkout exim-${EXIM_VERSION}
RUN ldconfig
WORKDIR src
RUN mkdir Local
RUN cp /DEBIAN/EDITME Local/Makefile
RUN EXIM_RELEASE_VERSION=${EXIM_VERSION} make -j6
RUN make install
RUN cp -a /opt/exim4/* /mc-exim/opt/exim4/
RUN cp -r /DEBIAN /mc-exim/
WORKDIR /
RUN sed -i 's/__INSTVER__/'$EXIM_VERSION'/' /mc-exim/DEBIAN/control
RUN sed -i 's/__INSTSIZE__/'$(du -sk /mc-exim | cut -f1)'/' /mc-exim/DEBIAN/control
WORKDIR /
RUN dpkg-deb -b -Z gzip /mc-exim /mc-exim-${EXIM_VERSION}_amd64.deb
CMD lintian /mc-exim-${EXIM_VERSION}_amd64.deb
