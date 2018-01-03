FROM floriangeigl/datascience:latest
LABEL maintainer="florian.geigl@gmail.com"

#install julia & packages (add your packages to package_install.jl)
COPY ./julia /tmp/
RUN ["/bin/bash", "-c", "\
    conda create -n julia julia libffi -y --no-update-dependencies && \
    source activate julia && \ 
    # install julia-packages
    julia /tmp/package_install.jl 2>&1 | tee /var/log/julia_pkg_installs.log  && \
    source deactivate && \
    layer_cleanup.sh"]

# Install R, R-packages and r-server (use conda install r-cran-* packages or add your packages to package_install.r)
COPY ./r /tmp/
RUN ["/bin/bash", "-c", "\
    conda create -n R r -c r -y --no-update-dependencies && \
    source activate R && \
    cat /tmp/Rprofile >> /root/.Rprofile && \
    conda install -n R r-base r-essentials r-recommended gcc_linux-64 gxx_linux-64 gfortran_linux-64 boost \
      r-ggplot2 r-gtools r-xml r-xml2 r-plyr r-rcurl \
      r-data.table r-knitr r-dplyr r-rjsonio r-nmf r-igraph r-futile.logger \
      r-zoo r-gdata r-catools r-lmtest r-gplots r-htmltools r-htmlwidgets r-dt \
      -c bioconda -c r -c BioBuilds -y --no-update-dependencies && \
    Rscript /tmp/package_install.r 2>&1 | tee /var/log/r_pkg_installs.log && \
    # install r-server
    useradd -m rstudio && \
    # set user/password for rstudio-server
    echo 'rstudio:rstudio' | chpasswd && \
    cat /tmp/Rprofile >> /home/rstudio/.Rprofile && \
    chown -R rstudio /home/rstudio/ && chgrp -R rstudio /home/rstudio/ && \
    VER=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) && \
    wget -q http://download2.rstudio.org/rstudio-server-${VER}-amd64.deb && \
    dpkg -i rstudio-server-${VER}-amd64.deb && \
    rm rstudio-server-*-amd64.deb && \
    ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin && \
    ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc-citeproc /usr/local/bin && \
    wget https://github.com/jgm/pandoc-templates/archive/master.zip && \
    mkdir -p /opt/pandoc/templates && unzip master.zip && \
    cp -r pandoc-templates*/* /opt/pandoc/templates && rm -rf pandoc-templates* && \
    mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates && \
    source deactivate && \
    cp /tmp/start_rstudio_server.sh ~/start_rstudio_server.sh && \
    # add r-studio server to supervisord
    cat /tmp/supervisord.conf >> /etc/supervisor/conf.d/supervisord.conf && \
    layer_cleanup.sh"]
        
# Expose r-studio-server
EXPOSE 8787
