## Sakura
The central repository for both the **Sakura** `Dockerfile` (to build a development image) and the *current* database required to bootstrap your environment.

## Getting started
You'll need to build the container first. Make sure to give it a tag that you can remember:

    docker build -t your_repo:and_tag .

This will compile the container. After it's done building the image you can make sure it's actually there:

    docker image list

And you should see the `your_repo:and_tag` image in the list of images. 

As this is supposed to be a development container it's expected that you'll launch it interactively. Also, we need to make sure to map the *exposed* 7999 port to the container's host, in this case we'll map port 7999 from the container to port 4000 on the host operating system:

    docker run -it -p 4000:7999 your_repo:and_tag /bin/bash

> As an aside, in the command above, the `i` and `t` flags we are gonna run this container in interactive mode and with a **tty** (terminal attached) attached.j The `p` flag is our port mapping. Finally we specify the `repository:tag` image to run and the main command (in this case we startup `bash` the prototypical command-line executable on Ubuntu).

This should bring you into Ubuntu and you should've ended up in the `/app` directory. From here we can launch the MOO:

    ./moo database.db database.db.new &

You'll have to substitute `database.db` with any of the available `.db` files in the `/app` directory though.