FROM docker.io/realcurrents/amzn-mro-3.5.1:base

ENV LD_LIBRARY_PATH /var/task/lib64:/usr/local/lib
ENV PATH /var/task/adam/bin:/var/task/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV REXEC R
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

RUN cd /var/task && \
    curl -LO https://real-currents.s3-us-west-1.amazonaws.com/r/ghc-8.10.2-x86_64-fedora27-linux.tar.xz && \
    tar -xf ghc-8.10.2-x86_64-fedora27-linux.tar.xz && \
    cd ghc* && \
    ./configure --prefix=/var/task && \
    make install && \
    cd .. && \
    export LD_LIBRARY_PATH="$PWD/lib64;$PWD/lib" && \
    cd bin && \
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
    rm -rf lib
RUN cd /var/task && \
    export RPROFILE="$(echo $(/var/task/bin/R -f /var/task/setup.R  | grep '/Rprofile') | grep -o '[A-Z|a-z|\/][A-Z|a-z|0-9|\:|\/|\.|\_]*')" && \
    echo $(for rp in $RPROFILE; do echo 'options(repos = list(CRAN="http://cran.rstudio.com/"))' >> $rp; done;) && \
    Rscript -e 'remove.packages(c("curl","httr"));' && \
    echo -e '\nexport CURL_CA_BUNDLE=/var/task/lib64/R/lib/microsoft-r-cacert.pem' >> ~/.bashrc && \
    echo -e '\nexport LC_ALL=C.UTF-8' >> ~/.bashrc && \
    echo -e '\nexport LANG=C.UTF-8' >> ~/.bashrc && \
    Rscript -e 'install.packages(c("curl", "httr", "Rcpp")); Sys.setenv(CURL_CA_BUNDLE="/var/task/lib64/R/lib/microsoft-r-cacert.pem")' && \
    Rscript -e 'install.packages(c("devtools", "jsonlite", "magick", "magrittr", "openxlsx", "remotes", "reticulate", "rmarkdown", "rgdal", "rgeos", "sf", "sp", "stringr", "tidyverse", "DT")); devtools::install_github("rte-antares-rpackage/manipulateWidget", upgrade = FALSE); devtools::install_github("rstudio/shiny", upgrade = FALSE); devtools::install_version("rgl", version = "0.100.19", dependencies = FALSE); devtools::install_github("tylermorganwall/rayimage@7a9a138e10e19119c88e960f9cfb191d1fdae002", upgrade = FALSE); devtools::install_github("tylermorganwall/terrainmeshr@e112055e47033508cc45c8246b8dc0a0e94920f7", upgrade = FALSE); devtools::install_github("tylermorganwall/rayshader@d0c9bd94be95c44eff6e7d8da5eadff070dc11db", upgrade = FALSE);' && \
    Rscript -e 'devtools::install_version("blogdown", version = "0.20", upgrade = FALSE); blogdown::install_hugo("0.48", extended = TRUE, force = TRUE, use_brew = FALSE);' && \
    cp /root/bin/hugo /var/task/bin/ && \
    rm /root/bin/hugo && \
    Rscript -e 'remotes::install_cran("azuremlsdk"); azuremlsdk::install_azureml(envnam = "r-reticulate", conda_python_version = "3.5.3", restart_session = TRUE, remove_existing_env = FALSE); reticulate::use_python(python = "/var/task/adam/envs/r-reticulate/bin/python", required = TRUE); reticulate::use_condaenv(condaenv = "r-reticulate"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install azureml"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install azure-ml-api-sdk"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install azureml.core"); system("/var/task/adam/envs/r-reticulate/bin/python -m pip install --upgrade azureml-sdk[notebooks,contrib]"); save.image();'  &&\
    echo $(for rp in $RPROFILE; do echo 'load("/var/task/.RData")' >> $rp; done;) && \
    echo $(for rp in $RPROFILE; do echo 'reticulate::use_python(python = "/var/task/adam/envs/r-reticulate/bin/python", required = TRUE)' >> $rp; done;) && \
    echo $(for rp in $RPROFILE; do echo 'reticulate::use_condaenv(condaenv = "r-reticulate")' >> $rp; done;)

WORKDIR /data
ENTRYPOINT [ "bash", "-c", "/var/task/bin/$REXEC $0 $1 $2 $3 $4 $5 $6 $7 $8 $9" ]
CMD [ "", "", "", "", "", "", "", "", "", "" ]
