# You could try other base images if you want.
FROM ubuntu

# Your choice.
WORKDIR /app

# By default, the MOO runs on port 7999 so we'll expose that.
EXPOSE 7999

# We need this to stuff to build the hellcore source
RUN apt-get update && apt-get install -y \
    make \
    gperf \
    byacc \
    flex \
    autoconf \
    git

# We'll clone the hellcore source from necanthrope which
# seems legit. With the prerequisites above we should be able 
# to compile this thing. Just ignore the warnings.
WORKDIR /app/hellcore
RUN git clone https://github.com/necanthrope/hellcore .
RUN ./build.sh

# Let's copy over the executable and databases for convenience.
RUN cp ./src/moo ..
RUN cp ./hellcore.db ..
RUN cp ./src/Minimal.db ../minimal.db

# So now we just have to pull in the latest sakura database.
WORKDIR /app/sakura
RUN git clone https://github.com/basp/sakura .
RUN cp ./sakura.db ..

# And here we are.
WORKDIR /app