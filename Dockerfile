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

WORKDIR /app/hellcore
RUN git clone https://github.com/necanthrope/hellcore .
RUN ./build.sh
RUN cp ./src/moo ..
RUN cp ./hellcore.db ..
RUN cp ./src/Minimal.db ../minimal.db

WORKDIR /app/sakura
RUN git clone https://github.com/basp/sakura .
RUN cp ./sakura.db ..

WORKDIR /app