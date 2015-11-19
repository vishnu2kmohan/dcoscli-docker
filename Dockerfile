FROM alpine:edge

MAINTAINER Vishnu Mohan <vishnu@mesosphere.com>

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    ALPINE_EDGE_TESTING_REPO="http://dl-1.alpinelinux.org/alpine/edge/testing/" \
    ALPINE_GLIBC_BASE_URL="https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64" \
    ALPINE_GLIBC_PACKAGE="glibc-2.21-r2.apk" \
    ALPINE_GLIBC_BIN_PACKAGE="glibc-bin-2.21-r2.apk" \
    KUBECTL_URL="https://github.com/mesosphere/kubernetes/releases/download" \
    KUBECTL_VERSION=v1.0.6-v0.6.5

# Here we use several hacks collected from https://github.com/gliderlabs/docker-alpine/issues/11:
# 1. install GLibc (which is not the cleanest solution at all)
# 2. hotfix /etc/nsswitch.conf, which is apperently required by glibc and is not used in Alpine Linux
RUN apk --update add \
    bash \
    curl \
    ca-certificates \
    git \
    jq \
    python3 \
    py-virtualenv \
    openjdk7-jre-base \
    openssh-client \
    readline \
    && apk add --update --repository ${ALPINE_EDGE_TESTING_REPO} tini \
    && cd /tmp \
    && wget ${ALPINE_GLIBC_BASE_URL}/${ALPINE_GLIBC_PACKAGE} ${ALPINE_GLIBC_BASE_URL}/${ALPINE_GLIBC_BIN_PACKAGE} \
    && apk add --allow-untrusted ${ALPINE_GLIBC_PACKAGE} ${ALPINE_GLIBC_BIN_PACKAGE} \
    && echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf \
    && wget ${KUBECTL_URL}/${KUBECTL_VERSION}/kubectl-${KUBECTL_VERSION}-linux-amd64.tgz \
    && tar xzf kubectl-${KUBECTL_VERSION}-linux-amd64.tgz -C /usr/local/bin \
    && rm /tmp/* /var/cache/apk/*

RUN adduser -s /bin/bash -G users -D dcoscli
WORKDIR /home/dcoscli
USER dcoscli
RUN mkdir -p /home/dcoscli/.dcos \
    && mkdir -p /home/dcoscli/.dcos/cache
COPY dcos.toml /home/dcoscli/.dcos/
RUN virtualenv -p python3 . \
    && bash -c \
    'source bin/activate \
    && pip install --upgrade httpie \
    && pip install --upgrade dcoscli \
    && dcos package update --validate \
    && dcos package install --cli arangodb --yes \
    && dcos package install --cli cassandra --yes \
    && dcos package install --cli hdfs --yes \
    && dcos package install --cli kafka --yes \
    && dcos package install --cli riak --yes \
    && dcos package install --cli spark --yes \
    && dcos package install --cli swarm --yes \
    && deactivate'

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/local/bin/dcos.sh"]

# Add local files as late as possible to stay cache friendly`
COPY dcos.sh /usr/local/bin/
