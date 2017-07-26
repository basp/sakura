FROM ubuntu

WORKDIR /app

EXPOSE 7999

RUN apt-get update && apt-get install -y \
    make \
    gperf \
    byacc \
    flex \
    autoconf \
    git

RUN git clone https://github.com/necanthrope/HellCore .

RUN ./build.sh

RUN cp ./src/moo .
