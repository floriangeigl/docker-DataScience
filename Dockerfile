FROM kaggle/python:latest
MAINTAINER Florian Geigl <florian.geigl@gmail.com>

# Install graph-tool
RUN apt-key update && apt-get update && \
    apt-key adv --keyserver pgp.skewed.de --recv-key 98507F25 && \
    touch /etc/apt/sources.list.d/graph-tool.list && \
    echo 'deb http://downloads.skewed.de/apt/jessie jessie main' >> /etc/apt/sources.list.d/graph-tool.list && \
    echo 'deb-src http://downloads.skewed.de/apt/jessie jessie main' >> /etc/apt/sources.list.d/graph-tool.list && \
    apt-get update && apt-get install -y --no-install-recommends python3-graph-tool && \
    ln -s /usr/lib/python3/dist-packages/graph_tool /opt/conda/lib/python3.5/site-packages/graph_tool && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
    
# Install other apt stuff
RUN apt-key update && apt-get update && \
    # add more packages here \
    apt-get install bash-completion vim screen htop less git mercurial subversion openssh-server \ 
    -y --no-install-recommends && \ 
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Setup ssh access
RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
    
# Install python2.7 for conda
# add python2.7 packages here
RUN conda create -n py27 python=2.7 anaconda seaborn flake8 -y && \
    pip install influxdb && \
    conda clean -i -l -t -y
    
# Install R 
RUN gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
    gpg -a --export E084DAB9 | sudo apt-key add - && \
    echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list.d/r-cran.list && \
    apt-key update && \
    apt-get update && \
    apt-get install r-base r-cran-rodbc r-cran-ggplot2 r-cran-gtools r-cran-xml r-cran-getopt r-cran-plyr \
    r-cran-rcurl -y --no-install-recommends --allow-unauthenticated && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
    
# Install RStudio-Server
RUN apt-key update && apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    file \
    git \
    libapparmor1 \
    libedit2 \
    libcurl4-openssl-dev \
    libssl-dev \
    lsb-release \
    psmisc \
    python-setuptools \
    sudo \
    && VER=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
    && wget -q http://download2.rstudio.org/rstudio-server-${VER}-amd64.deb \
    && dpkg -i rstudio-server-${VER}-amd64.deb \
    && rm rstudio-server-*-amd64.deb \
    && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin \
    && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc-citeproc /usr/local/bin \
    && wget https://github.com/jgm/pandoc-templates/archive/1.15.0.6.tar.gz \
    && mkdir -p /opt/pandoc/templates && tar zxf 1.15.0.6.tar.gz \
    && cp -r pandoc-templates*/* /opt/pandoc/templates && rm -rf pandoc-templates* \
    && mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/
    
# create r-user and default-credentials
RUN useradd -m rstudio && \
    echo "rstudio:rstudio" | chpasswd

# Install conda python3 libs
RUN conda install pycairo cairomm libiconv jupyterlab flake8 -c conda-forge -c floriangeigl -y && \
    conda clean -i -l -t -y
# conda update -y conda conda-build pip && \

# Install pip libs
# add python3 packages here
RUN pip install tabulate ftfy pyflux cookiecutter segtok gensim textblob pandas-ply influxdb
# python -m textblob.download_corpora

#install julia
RUN apt-get update && apt-get install julia libzmq3-dev -y --no-install-recommends && \
    echo 'Pkg.add("IJulia")' | julia && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
    
# Expose Jupyter port.
EXPOSE 8888
EXPOSE 8787
EXPOSE 22

# Start Jupyter at container start
CMD ["startup.sh"]

# Copy Jupyter start script into the container.
COPY start-notebook.sh /usr/local/bin/
COPY start-r-server.sh /usr/local/bin/
COPY start-ssh-server.sh /usr/local/bin/

# fix bash-completion for apt
COPY bash_completion_fix.sh /tmp/
RUN cat /tmp/bash_completion_fix.sh >> /etc/bash.bashrc

# Copy startup script into the container.
COPY startup.sh /usr/local/bin/

# Fix permissions
RUN chmod +x /usr/local/bin/start-notebook.sh && \
    chmod +x /usr/local/bin/startup.sh && \
    chmod +x /usr/local/bin/start-r-server.sh && \
    chmod +x /usr/local/bin/start-ssh-server.sh
