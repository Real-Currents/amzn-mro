FROM docker.io/real-currents/amzn-mro-3.5.1:base

ENV LD_LIBRARY_PATH /var/task/lib64
ENV REXEC R

RUN yum groupinstall -y "Development Tools" && \
    yum install -y libcurl libcurl-devel readline-static readline-devel
RUN cd /var/task && source /var/task/setup.sh && \
    export RPROFILE="$(echo $(/var/task/bin/R -f /var/task/setup.R  | grep '/Rprofile') | grep -o '[A-Z|a-z|\/][A-Z|a-z|0-9|\:|\/|\.|\_]*')" && \
    echo $RPROFILE && \
    echo $(for rp in $RPROFILE; do echo 'options(repos = list(CRAN="http://cran.rstudio.com/"))' >> $rp; done;)

WORKDIR /data
ENTRYPOINT [ "bash", "-c", "/var/task/bin/$REXEC $0 $1 $2 $3 $4 $5 $6 $7 $8 $9" ] 
CMD [ "", "", "", "", "", "", "", "", "", "" ]
