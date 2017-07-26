FROM ubuntu

WORKDIR /app

EXPOSE 7999

RUN apt-get update && apt-get install -y \
    make \
    gperf \
    byacc \
    flex \
    autoconf \
    git \
    vim
