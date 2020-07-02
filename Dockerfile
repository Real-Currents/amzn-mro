FROM docker.io/realcurrents/amzn-mro-3.5.1:base

ENV LD_LIBRARY_PATH /var/task/lib64
ENV REXEC R

RUN yum groupinstall -y "Development Tools" && \
    yum install -y git less libcurl libcurl-devel readline-static readline-devel libcairo libpng12 libXt && \
    yum install -y gmp-devel freeglut-devel python-devel zlib-devel gcc m4 pango pango-devel python3-pip which xz unzip zip
RUN cd /var/task && curl -o mro-3.5.1.zip https://real-currents.s3-us-west-1.amazonaws.com/r/mro-3.5.1.zip && \
    unzip -o mro-3.5.1.zip && rm mro-3.5.1.zip && source /var/task/setup.sh && \
    cp /usr/lib64/libgmp.so.10 lib64/libgmp.so.3 && ldconfig && \
    curl -LO https://downloads.haskell.org/~ghc/latest/ghc-8.10.1-x86_64-fedora27-linux.tar.xz && \
    tar -xf ghc-8.10.1-x86_64-fedora27-linux.tar.xz && \
    cd ghc* && \
    ./configure --prefix=/var/task && \
    make install && \
    cd .. && \
    export LD_LIBRARY_PATH="$PWD/lib64;$PWD/lib" && \
    cd bin && \
    curl -LO https://www.haskell.org/cabal/release/cabal-install-1.24.0.0/cabal-install-1.24.0.0-x86_64-unknown-linux.tar.gz && \
    tar xf cabal* && \
    chmod +x cabal* &&\
    cabal sandbox init && \
    cabal update && \
    cabal install hsb2hs && \
    cp .cabal-sandbox/bin/* ./  && \
    curl -LO https://github.com/serverlesspub/pandoc-aws-lambda-binary/raw/2abd2a4e09a3ca42d3b3184fde7137ed16275b7d/vendor/pandoc.gz && \
    gunzip pandoc.gz && \
    chmod +x pandoc* && \
    cd .. && \
    rm -rf lib && \
    export RPROFILE="$(echo $(/var/task/bin/R -f /var/task/setup.R  | grep '/Rprofile') | grep -o '[A-Z|a-z|\/][A-Z|a-z|0-9|\:|\/|\.|\_]*')" && \
    echo $RPROFILE && \
    echo $(for rp in $RPROFILE; do echo 'options(repos = list(CRAN="http://cran.rstudio.com/"))' >> $rp; done;) && \
    Rscript -e 'install.packages("jsonlite"); install.packages("openxlsx"); install.packages("rmarkdown"); install.packages("stringr"); install.packages("tidyverse");install.packages("DT"); install.packages("blogdown"); blogdown::install_hugo(); install.packages("devtools"); devtools::install_github("hrbrmstr/markdowntemplates");'

WORKDIR /data
ENTRYPOINT [ "bash", "-c", "/var/task/bin/$REXEC $0 $1 $2 $3 $4 $5 $6 $7 $8 $9" ] 
CMD [ "", "", "", "", "", "", "", "", "", "" ]
