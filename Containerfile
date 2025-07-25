FROM debian:bookworm-slim
LABEL maintainer="joe@ajoeofalltrades.dev" \
      description="DNS Audit Environment with dig, amass, zonemaster, dnsrecon, and related tools"

ENV DEBIAN_FRONTEND=noninteractive

# Install Debian packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential ca-certificates curl git gnupg python3 python3-venv python3-pip \
    perl libssl-dev libidn11-dev libjson-perl libnet-dns-perl libio-socket-inet6-perl \
    libsocket6-perl libyaml-libyaml-perl bind9-dnsutils jq dnsutils net-tools iputils-ping \
    traceroute unzip wget pandoc make golang-go libgpgme-dev \
    libldns-dev libidn2-dev openssl \
    libjson-xs-perl libnet-ldns-perl libzonemaster-perl \
    libgetopt-long-descriptive-perl libtext-reflow-perl \
    libmoosex-getopt-perl libintl-perl \
    cpanminus libck-dev libnghttp2-dev autoconf automake libtool pkg-config \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up Python virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Python tools
RUN pip install --no-cache-dir dnsrecon dnsviz git+https://github.com/farrokhi/dnsdiag.git

# Golang-based dmarc-cat installation
RUN export GOPATH=/go && \
    go install github.com/keltia/dmarc-cat@latest

# Install Zonemaster Dependencies and Zonemaster CLI
RUN cpanm --notest Zonemaster::LDNS  && \
    cpanm --notest Zonemaster::Engine && \
    cpanm --notest Zonemaster::CLI

# Install Amass
RUN curl -L -o /tmp/amass.zip https://github.com/owasp-amass/amass/releases/latest/download/amass_linux_amd64.zip && \
    unzip /tmp/amass.zip -d /usr/local/bin && rm /tmp/amass.zip

# Install dnsperf & resperf from source
RUN git clone https://github.com/DNS-OARC/dnsperf.git /opt/dnsperf && \
    cd /opt/dnsperf && \
    ./autogen.sh && ./configure && make && make install && \
    rm -rf /opt/dnsperf

# Install spf-tools shell script suite
RUN git clone https://github.com/spf-tools/spf-tools.git /opt/spf-tools && \
    ln -s /opt/spf-tools/despf.sh /usr/local/bin/despf.sh && \
    ln -s /opt/spf-tools/normalize.sh /usr/local/bin/normalize.sh && \
    ln -s /opt/spf-tools/simplify.sh /usr/local/bin/simplify.sh && \
    ln -s /opt/spf-tools/mkblocks.sh /usr/local/bin/mkblocks.sh && \
    ln -s /opt/spf-tools/compare.sh /usr/local/bin/compare.sh

WORKDIR /opt/audit
CMD ["bash"]