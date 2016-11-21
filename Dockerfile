FROM kaggle/python:latest
MAINTAINER Florian Geigl <florian.geigl@gmail.com>

# Install apt stuff, graph-tool, setup ssh and update conda
RUN apt-key update && apt-get update && \
    # add more packages here \
    apt-get install bash-completion vim screen htop less git mercurial subversion openssh-server \ 
        -y --no-install-recommends && \ 
    # install graph-tool
    apt-key adv --keyserver pgp.skewed.de --recv-key 98507F25 && \
    touch /etc/apt/sources.list.d/graph-tool.list && \
    echo 'deb http://downloads.skewed.de/apt/jessie jessie main' >> /etc/apt/sources.list.d/graph-tool.list && \
    echo 'deb-src http://downloads.skewed.de/apt/jessie jessie main' >> /etc/apt/sources.list.d/graph-tool.list && \
    apt-get update && apt-get install -y --no-install-recommends python3-graph-tool && \
    ln -s /usr/lib/python3/dist-packages/graph_tool /opt/conda/lib/python3.5/site-packages/graph_tool && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/* && \
    # setup ssh
    mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    # update conda
    conda update conda conda-env conda-build pip -y

#install julia & packages (add your packages to package_install.jl)
COPY package_install.jl /tmp/
RUN apt-key update && apt-get update && \
    # install required libs
    apt-get install -y --no-install-recommends gettext hdf5-tools libpcre3-dev build-essential \
      gfortran m4 cmake libssl-dev libcurl4-openssl-dev libzmq3-dev && \
    # install julia
    conda install julia \
      -c bioconda -y && \
    echo "Install packages from package_install.jl..." && \
    # install julia-packages
    julia /tmp/package_install.jl >> /var/log/julia_pkg_installs.log 2>&1 && \
    # cleanup
    conda clean -i -l -t -y

# Install python2.7 for conda
# add python2.7 packages here
RUN conda create -n py27 python=2.7 anaconda seaborn flake8 -y && \
    conda clean -i -l -t -y && \
    pip install influxdb && \
    rm -rf ~/.cache/pip
    
# Install R, R-packages and r-server (use conda install r-cran-* packages or add your packages to package_install.r)
COPY package_install.r \
    Rprofile \
    /tmp/
RUN apt-key update && apt-get update && \
    apt-get install -y --no-install-recommends unixodbc-dev libxtst6 && \
    conda install r r-base r-essentials r-recommended r-ggplot2 r-gtools r-xml r-xml2 r-plyr r-rcurl \
      r-data.table r-knitr r-dplyr r-rjsonio r-nmf r-igraph r-dendextend r-plotly \
      r-zoo r-gdata r-catools r-lmtest r-gplots r-htmltools r-htmlwidgets r-scatterplot3d r-dt \
      -c bioconda -c r -c BioBuilds -y && \
    cat /tmp/Rprofile >> /root/.Rprofile && \
    echo "Install packages from package_install.r..." && \
    Rscript /tmp/package_install.r >> /var/log/r_pkg_installs.log 2>&1 && \
    conda clean -i -l -t -y && \
    # install r-server
    useradd -m rstudio && \
    echo "rstudio:rstudio" | chpasswd && \
    echo 'setwd("/data/")' >> /root/.Rprofile && \
    echo 'setwd("/data/")' >> /home/rstudio/.Rprofile && \
    cat /tmp/Rprofile >> /home/rstudio/.Rprofile && \
    chown -R rstudio /home/rstudio/ && chgrp -R rstudio /home/rstudio/ && \
    apt-get install -y --no-install-recommends ca-certificates file git libapparmor1 libedit2 \
        libcurl4-openssl-dev libssl-dev lsb-release psmisc python-setuptools sudo && \
    VER=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) && \
    wget -q http://download2.rstudio.org/rstudio-server-${VER}-amd64.deb && \
    dpkg -i rstudio-server-${VER}-amd64.deb && \
    rm rstudio-server-*-amd64.deb && \
    ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin && \
    ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc-citeproc /usr/local/bin && \
    wget https://github.com/jgm/pandoc-templates/archive/1.15.0.6.tar.gz && \
    mkdir -p /opt/pandoc/templates && tar zxf 1.15.0.6.tar.gz && \
    cp -r pandoc-templates*/* /opt/pandoc/templates && rm -rf pandoc-templates* && \
    mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates && \
    # cleanup
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
        
# Install conda/pip python3 libs
RUN conda install pycairo cairomm libiconv jupyterlab flake8 librabbitmq \
      -c conda-forge -c floriangeigl -y && \
    jupyter serverextension enable --py jupyterlab --sys-prefix && \
    conda clean -i -l -t -y && \
    pip install tabulate ftfy pyflux cookiecutter segtok gensim textblob pandas-ply influxdb && \
    rm -rf ~/.cache/pip
    
# Copy some start script into the container.
COPY start-notebook.sh  \
    start_jupyterlabs.sh \
    start-r-server.sh \
    start-ssh-server.sh \
    export_environment.sh \
    startup.sh \
    /usr/local/bin/

# Fix permissions
RUN chmod +x /usr/local/bin/start-notebook.sh && \
    chmod +x /usr/local/bin/start_jupyterlabs.sh && \
    chmod +x /usr/local/bin/startup.sh && \
    chmod +x /usr/local/bin/start-r-server.sh && \
    chmod +x /usr/local/bin/start-ssh-server.sh && \
    chmod +x /usr/local/bin/export_environment.sh

# fix bash-completion for apt
COPY bash_completion_fix.sh /tmp/
RUN cat /tmp/bash_completion_fix.sh >> /etc/bash.bashrc && \ 
    echo "if [ -f /etc/bash_completion ]; then" >> ~/.bash_profile && \
    echo "  . /etc/bash_completion" >> ~/.bash_profile && \
    echo "fi" >> ~/.bash_profile && \
    rm -rf /tmp/*

# Expose jupyter notebook, jupyter labs, r-studio-server and ss port.
EXPOSE 8888 8889 8787 22

# Start all scripts
CMD ["startup.sh"]
