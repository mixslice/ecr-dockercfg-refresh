FROM alpine:3.4

MAINTAINER bensonz <mr.bz@hotmail.com>

ADD https://s3.cn-north-1.amazonaws.com.cn/kubernetes-bin/kubectl /usr/local/bin/
COPY ecr-dockercfg-refresh.sh /usr/local/bin/

RUN set -x && \
    apk add --no-cache \
        curl \
        ca-certificates \
        python \
        py-pip && \
    pip install awscli && \
    chmod +x /usr/local/bin/kubectl /usr/local/bin/ecr-dockercfg-refresh.sh

# See script for env that can drive execution. Ex: To only run once set REFRESH_INTERVAL=0
# ENV REFRESH_INTERVAL=0

CMD "/usr/local/bin/ecr-dockercfg-refresh.sh"
