FROM docker.io/realcurrents/amzn-mro-3.5.1:base as base

ENV LD_LIBRARY_PATH /var/task/lib64:/var/task/lib:/usr/local/lib64:/usr/local/lib:/usr/lib64
ENV PATH /var/task/adam/bin:/var/task/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV REXEC R
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

RUN cd /tmp && \
    curl -LO https://real-currents.s3-us-west-1.amazonaws.com/r/ghc-8.10.2-x86_64-fedora27-linux.tar.xz && \
    tar -xf ghc-8.10.2-x86_64-fedora27-linux.tar.xz && \
    cd ghc* && \
    ./configure --prefix=/var/task && \
    make install

RUN cd /var/task && \
    cp /usr/lib64/libgmp.so.10 lib64/libgmp.so.3 && ldconfig && cd bin && \
    curl -LO https://real-currents.s3-us-west-1.amazonaws.com/r/cabal-install-1.24.0.0-x86_64-unknown-linux.tar.gz && \
    tar xf cabal* && \
    chmod +x cabal* &&\
    cabal sandbox init && \
    cabal update && \
    cabal install hsb2hs && \
    cd .cabal-sandbox/bin/  && \
    curl -LO https://real-currents.s3-us-west-1.amazonaws.com/r/pandoc.gz && \
    gunzip pandoc.gz && \
    chmod +x pandoc* && \
    cp ./* /usr/local/bin  && \
    cd ../../../ && \
    rm -rf lib && \
    cp -r /usr/local/bin/* /var/task/bin/  && \
    cp -r /usr/local/lib/* /var/task/lib64/

RUN cd /var/task && source /var/task/setup.sh && ldconfig && \
    export RPROFILE="$(echo $(/var/task/bin/R -f /var/task/setup.R  | grep '/Rprofile') | grep -o '[A-Z|a-z|\/][A-Z|a-z|0-9|\:|\/|\.|\_]*')" && \
    echo $(for rp in $RPROFILE; do echo 'options(repos = list(CRAN="http://cran.rstudio.com/"))' >> $rp; done;) && \
    /var/task/bin/Rscript -e 'remove.packages(c("curl","httr"));' && \
    echo -e '\nexport CURL_CA_BUNDLE=/var/task/lib64/R/lib/microsoft-r-cacert.pem' >> ~/.bashrc && \
    echo -e '\nexport LC_ALL=C.UTF-8' >> ~/.bashrc && \
    echo -e '\nexport LANG=C.UTF-8' >> ~/.bashrc && \
    /var/task/bin/Rscript -e 'install.packages(c("curl", "httr", "Rcpp")); Sys.setenv(CURL_CA_BUNDLE="/var/task/lib64/R/lib/microsoft-r-cacert.pem")' && \
    /var/task/bin/Rscript -e 'install.packages(c("rlang", "devtools", "jsonlite", "magick", "magrittr", "openxlsx", "remoter", "remotes", "reticulate", "rmarkdown", "rgdal", "rgeos", "sf", "sp", "stringi", "stringr", "tidyverse"));' && \
    /var/task/bin/Rscript -e 'devtools::install_version("blogdown", version = "0.20", upgrade = FALSE); blogdown::install_hugo("0.48", extended = TRUE, force = TRUE, use_brew = FALSE);' && \
    cp /root/bin/hugo /var/task/bin/ && \
    rm /root/bin/hugo && \
    /var/task/bin/Rscript -e 'remotes::install_cran("azuremlsdk"); azuremlsdk::install_azureml(envnam = "r-reticulate", conda_python_version = "3.5.3", restart_session = TRUE, remove_existing_env = FALSE); reticulate::use_python(python = "/var/task/adam/envs/r-reticulate/bin/python", required = TRUE); reticulate::use_condaenv(condaenv = "r-reticulate"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install azureml"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install azure-ml-api-sdk"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install azureml.core"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install --upgrade azureml-sdk[notebooks,contrib]"); save.image();'  &&\
    echo $(for rp in $RPROFILE; do echo 'load("/var/task/.RData")' >> $rp; done;) && \
    echo $(for rp in $RPROFILE; do echo 'reticulate::use_python(python = "/var/task/adam/envs/r-reticulate/bin/python", required = TRUE)' >> $rp; done;) && \
    echo $(for rp in $RPROFILE; do echo 'reticulate::use_condaenv(condaenv = "r-reticulate")' >> $rp; done;)

FROM docker.io/realcurrents/amzn-mro-3.5.1:origin as runtime
COPY --from=base /var/task /var/task

ENV GITHUB_TOKEN 68cb495f90397e6daf75993fbc34ce9d45952895
ENV GITHUB_PAT 68cb495f90397e6daf75993fbc34ce9d45952895
ENV LD_LIBRARY_PATH /var/task/lib64:/var/task/lib:/usr/local/lib64:/usr/local/lib:/usr/lib64
ENV PATH /var/task/adam/bin:/var/task/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV REXEC R

RUN yum -y update && \
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm && \
    yum -y install https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm && \
    yum install -y armadillo cmake dbus dbus-libs fontconfig gdal geos gmp jq proj proj-nad proj-epsg postgresql v8 \
            libcairo libcurl libcurl-devel libgomp libSM libjpeg-turbo-devel libpng12 libXt m4 openssl-devel \
            pandoc pango python-devel python3-pip readline-static tar which xz udunits2 udunits2-devel unzip && \
    yum reinstall -y libpng libpng-devel zlib zlib-devel && \
    yum clean all

WORKDIR /data

ENTRYPOINT [ "bash", "-c", "/var/task/bin/$REXEC $0 $1 $2 $3 $4 $5 $6 $7 $8 $9" ]
CMD [ "", "", "", "", "", "", "", "", "", "" ]
