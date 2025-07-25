FROM debian:bookworm-slim AS builder
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
LABEL maintainer="joe@ajoeofalltrades.dev" \
      description="DNS Audit Environment with dig, amass, zonemaster, dnsrecon, and related tools"

ENV DEBIAN_FRONTEND=noninteractive

# Install build and runtime dependencies
RUN set -e; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential="$(apt-cache show build-essential | awk '/^Version:/ {print $2; exit}')" \
        ca-certificates="$(apt-cache show ca-certificates | awk '/^Version:/ {print $2; exit}')" \
        curl="$(apt-cache show curl | awk '/^Version:/ {print $2; exit}')" \
        git="$(apt-cache show git | awk '/^Version:/ {print $2; exit}')" \
        gnupg="$(apt-cache show gnupg | awk '/^Version:/ {print $2; exit}')" \
        python3="$(apt-cache show python3 | awk '/^Version:/ {print $2; exit}')" \
        python3-venv="$(apt-cache show python3-venv | awk '/^Version:/ {print $2; exit}')" \
        python3-pip="$(apt-cache show python3-pip | awk '/^Version:/ {print $2; exit}')" \
        perl="$(apt-cache show perl | awk '/^Version:/ {print $2; exit}')" \
        libssl-dev="$(apt-cache show libssl-dev | awk '/^Version:/ {print $2; exit}')" \
        libidn11-dev="$(apt-cache show libidn11-dev | awk '/^Version:/ {print $2; exit}')" \
        libjson-perl="$(apt-cache show libjson-perl | awk '/^Version:/ {print $2; exit}')" \
        libnet-dns-perl="$(apt-cache show libnet-dns-perl | awk '/^Version:/ {print $2; exit}')" \
        libio-socket-inet6-perl="$(apt-cache show libio-socket-inet6-perl | awk '/^Version:/ {print $2; exit}')" \
        libsocket6-perl="$(apt-cache show libsocket6-perl | awk '/^Version:/ {print $2; exit}')" \
        libyaml-libyaml-perl="$(apt-cache show libyaml-libyaml-perl | awk '/^Version:/ {print $2; exit}')" \
        bind9-dnsutils="$(apt-cache show bind9-dnsutils | awk '/^Version:/ {print $2; exit}')" \
        jq="$(apt-cache show jq | awk '/^Version:/ {print $2; exit}')" \
        dnsutils="$(apt-cache show dnsutils | awk '/^Version:/ {print $2; exit}')" \
        net-tools="$(apt-cache show net-tools | awk '/^Version:/ {print $2; exit}')" \
        iputils-ping="$(apt-cache show iputils-ping | awk '/^Version:/ {print $2; exit}')" \
        traceroute="$(apt-cache show traceroute | awk '/^Version:/ {print $2; exit}')" \
        unzip="$(apt-cache show unzip | awk '/^Version:/ {print $2; exit}')" \
        wget="$(apt-cache show wget | awk '/^Version:/ {print $2; exit}')" \
        pandoc="$(apt-cache show pandoc | awk '/^Version:/ {print $2; exit}')" \
        make="$(apt-cache show make | awk '/^Version:/ {print $2; exit}')" \
        golang-go="$(apt-cache show golang-go | awk '/^Version:/ {print $2; exit}')" \
        libgpgme-dev="$(apt-cache show libgpgme-dev | awk '/^Version:/ {print $2; exit}')" \
        libldns-dev="$(apt-cache show libldns-dev | awk '/^Version:/ {print $2; exit}')" \
        libidn2-dev="$(apt-cache show libidn2-dev | awk '/^Version:/ {print $2; exit}')" \
        openssl="$(apt-cache show openssl | awk '/^Version:/ {print $2; exit}')" \
        libjson-xs-perl="$(apt-cache show libjson-xs-perl | awk '/^Version:/ {print $2; exit}')" \
        libnet-ldns-perl="$(apt-cache show libnet-ldns-perl | awk '/^Version:/ {print $2; exit}')" \
        libzonemaster-perl="$(apt-cache show libzonemaster-perl | awk '/^Version:/ {print $2; exit}')" \
        libgetopt-long-descriptive-perl="$(apt-cache show libgetopt-long-descriptive-perl | awk '/^Version:/ {print $2; exit}')" \
        libtext-reflow-perl="$(apt-cache show libtext-reflow-perl | awk '/^Version:/ {print $2; exit}')" \
        libmoosex-getopt-perl="$(apt-cache show libmoosex-getopt-perl | awk '/^Version:/ {print $2; exit}')" \
        libintl-perl="$(apt-cache show libintl-perl | awk '/^Version:/ {print $2; exit}')" \
        cpanminus="$(apt-cache show cpanminus | awk '/^Version:/ {print $2; exit}')" \
        libck-dev="$(apt-cache show libck-dev | awk '/^Version:/ {print $2; exit}')" \
        libnghttp2-dev="$(apt-cache show libnghttp2-dev | awk '/^Version:/ {print $2; exit}')" \
        autoconf="$(apt-cache show autoconf | awk '/^Version:/ {print $2; exit}')" \
        automake="$(apt-cache show automake | awk '/^Version:/ {print $2; exit}')" \
        libtool="$(apt-cache show libtool | awk '/^Version:/ {print $2; exit}')" \
        pkg-config="$(apt-cache show pkg-config | awk '/^Version:/ {print $2; exit}')" \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up Python virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:/usr/local/go/bin:$PATH"

# Install Python tools
RUN pip install --no-cache-dir \
    dnsrecon==1.1.0 \
    dnsviz==1.0.0 \
    git+https://github.com/farrokhi/dnsdiag.git@v1.0.0

# Golang-based dmarc-cat installation
RUN export GOPATH=/go && \
    go install github.com/keltia/dmarc-cat@latest && \
    mv /go/bin/dmarc-cat /usr/local/bin/dmarc-cat

# Install Zonemaster Dependencies and Zonemaster CLI
RUN cpanm --notest Zonemaster::LDNS && \
    cpanm --notest Zonemaster::Engine && \
    cpanm --notest Zonemaster::CLI

# Install Amass
RUN curl -L -o /tmp/amass.zip https://github.com/owasp-amass/amass/releases/latest/download/amass_linux_amd64.zip && \
    unzip /tmp/amass.zip -d /tmp && \
    mv /tmp/amass_linux_amd64/amass /usr/local/bin/amass && \
    rm -rf /tmp/amass_linux_amd64 /tmp/amass.zip

# Install dnsperf & resperf from source
RUN git clone https://github.com/DNS-OARC/dnsperf.git /opt/dnsperf
WORKDIR /opt/dnsperf
RUN ./autogen.sh && ./configure && make && make install && \
    rm -rf /opt/dnsperf
WORKDIR /

# Install spf-tools shell script suite
RUN git clone https://github.com/spf-tools/spf-tools.git /opt/spf-tools && \
    ln -s /opt/spf-tools/despf.sh /usr/local/bin/despf.sh && \
    ln -s /opt/spf-tools/normalize.sh /usr/local/bin/normalize.sh && \
    ln -s /opt/spf-tools/simplify.sh /usr/local/bin/simplify.sh && \
    ln -s /opt/spf-tools/mkblocks.sh /usr/local/bin/mkblocks.sh && \
    ln -s /opt/spf-tools/compare.sh /usr/local/bin/compare.sh

# Final runtime stage
FROM debian:bookworm-slim
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

RUN set -e; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates="$(apt-cache show ca-certificates | awk '/^Version:/ {print $2; exit}')" \
        curl="$(apt-cache show curl | awk '/^Version:/ {print $2; exit}')" \
        git="$(apt-cache show git | awk '/^Version:/ {print $2; exit}')" \
        gnupg="$(apt-cache show gnupg | awk '/^Version:/ {print $2; exit}')" \
        python3="$(apt-cache show python3 | awk '/^Version:/ {print $2; exit}')" \
        perl="$(apt-cache show perl | awk '/^Version:/ {print $2; exit}')" \
        libssl-dev="$(apt-cache show libssl-dev | awk '/^Version:/ {print $2; exit}')" \
        libidn11-dev="$(apt-cache show libidn11-dev | awk '/^Version:/ {print $2; exit}')" \
        libjson-perl="$(apt-cache show libjson-perl | awk '/^Version:/ {print $2; exit}')" \
        libnet-dns-perl="$(apt-cache show libnet-dns-perl | awk '/^Version:/ {print $2; exit}')" \
        libio-socket-inet6-perl="$(apt-cache show libio-socket-inet6-perl | awk '/^Version:/ {print $2; exit}')" \
        libsocket6-perl="$(apt-cache show libsocket6-perl | awk '/^Version:/ {print $2; exit}')" \
        libyaml-libyaml-perl="$(apt-cache show libyaml-libyaml-perl | awk '/^Version:/ {print $2; exit}')" \
        bind9-dnsutils="$(apt-cache show bind9-dnsutils | awk '/^Version:/ {print $2; exit}')" \
        jq="$(apt-cache show jq | awk '/^Version:/ {print $2; exit}')" \
        dnsutils="$(apt-cache show dnsutils | awk '/^Version:/ {print $2; exit}')" \
        net-tools="$(apt-cache show net-tools | awk '/^Version:/ {print $2; exit}')" \
        iputils-ping="$(apt-cache show iputils-ping | awk '/^Version:/ {print $2; exit}')" \
        traceroute="$(apt-cache show traceroute | awk '/^Version:/ {print $2; exit}')" \
        unzip="$(apt-cache show unzip | awk '/^Version:/ {print $2; exit}')" \
        wget="$(apt-cache show wget | awk '/^Version:/ {print $2; exit}')" \
        pandoc="$(apt-cache show pandoc | awk '/^Version:/ {print $2; exit}')" \
        libldns-dev="$(apt-cache show libldns-dev | awk '/^Version:/ {print $2; exit}')" \
        libidn2-dev="$(apt-cache show libidn2-dev | awk '/^Version:/ {print $2; exit}')" \
        openssl="$(apt-cache show openssl | awk '/^Version:/ {print $2; exit}')" \
        libjson-xs-perl="$(apt-cache show libjson-xs-perl | awk '/^Version:/ {print $2; exit}')" \
        libnet-ldns-perl="$(apt-cache show libnet-ldns-perl | awk '/^Version:/ {print $2; exit}')" \
        libzonemaster-perl="$(apt-cache show libzonemaster-perl | awk '/^Version:/ {print $2; exit}')" \
        libgetopt-long-descriptive-perl="$(apt-cache show libgetopt-long-descriptive-perl | awk '/^Version:/ {print $2; exit}')" \
        libtext-reflow-perl="$(apt-cache show libtext-reflow-perl | awk '/^Version:/ {print $2; exit}')" \
        libmoosex-getopt-perl="$(apt-cache show libmoosex-getopt-perl | awk '/^Version:/ {print $2; exit}')" \
        libintl-perl="$(apt-cache show libintl-perl | awk '/^Version:/ {print $2; exit}')" \
        libck-dev="$(apt-cache show libck-dev | awk '/^Version:/ {print $2; exit}')" \
        libnghttp2-dev="$(apt-cache show libnghttp2-dev | awk '/^Version:/ {print $2; exit}')" \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local /usr/local
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /opt/spf-tools /opt/spf-tools

RUN useradd -m dnspect && mkdir -p /opt/audit && chown -R dnspect /opt/audit

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:/usr/local/go/bin:$PATH"

WORKDIR /opt/audit
USER dnspect

CMD ["bash"]
