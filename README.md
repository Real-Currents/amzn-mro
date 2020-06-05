Microsoft R Open
================

    docker run -it --mount type=bind,source=.,destination=/data --privileged --rm docker.io/realcurrents/amzn-mro-3.5.1:latest

    docker run -it --mount type=bind,source=.,destination=/data --privileged --rm -e "REXEC=Rscript" docker.io/realcurrents/amzn-mro-3.5.1:latest "/data/src/script.R" "ARG1" "ARG2" "ARG3"

