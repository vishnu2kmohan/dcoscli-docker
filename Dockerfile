FROM alpine:edge

MAINTAINER Vishnu Mohan <vishnu@mesosphere.com>

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

ENV KUBECTL_VERSION v1.0.6-v0.6.5

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
    openssh-client && \
    cd /tmp && \
    wget "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk" \
         "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk" && \
    apk add --allow-untrusted glibc-2.21-r2.apk glibc-bin-2.21-r2.apk && \
    /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    wget "https://github.com/mesosphere/kubernetes/releases/download/$KUBECTL_VERSION/kubectl-$KUBECTL_VERSION-linux-amd64.tgz" && \
    tar xzf kubectl-v1.0.6-v0.6.5-linux-amd64.tgz -C /usr/local/bin && \
    rm /tmp/* /var/cache/apk/*

COPY dcos.sh /usr/local/bin/
RUN adduser -D dcoscli && \
    mkdir -p /home/dcoscli/.dcos
COPY dcos.toml /home/dcoscli/.dcos/
RUN chmod +x /usr/local/bin/dcos.sh && \
    chown -R dcoscli:dcoscli /home/dcoscli

WORKDIR /home/dcoscli
USER dcoscli
RUN virtualenv -p python3 .
RUN bash -c \
    'source bin/activate && \
    pip install --upgrade httpie && \
    pip install --upgrade dcoscli && \
    dcos package update --validate && \
    dcos package install --cli arangodb --yes && \
    dcos package install --cli cassandra --yes && \
    dcos package install --cli hdfs --yes && \
    dcos package install --cli kafka --yes && \
    dcos package install --cli riak --yes && \
    dcos package install --cli spark --yes && \
    dcos package install --cli swarm --yes && \
    deactivate'

ENTRYPOINT ["/usr/local/bin/dcos.sh"]
