FROM kaggle/python:latest
MAINTAINER Florian Geigl <florian.geigl@gmail.com>

# Install graph-tool
RUN apt-get update && \
    apt-key adv --keyserver pgp.skewed.de --recv-key 98507F25 && \
    touch /etc/apt/sources.list.d/graph-tool.list && \
    echo 'deb http://downloads.skewed.de/apt/jessie jessie main' >> /etc/apt/sources.list.d/graph-tool.list && \
    echo 'deb-src http://downloads.skewed.de/apt/jessie jessie main' >> /etc/apt/sources.list.d/graph-tool.list && \
    apt-get update && apt-get install -y --no-install-recommends python3-graph-tool && \
    ln -s /usr/lib/python3/dist-packages/graph_tool /opt/conda/lib/python3.5/site-packages/graph_tool && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
    
# Install other apt stuff
RUN apt-get update && \
    # add more packages here \
    apt-get install bash-completion vim screen htop less git mercurial subversion \ 
    -y --no-install-recommends && \ 
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Install python2.7 for conda
# add python2.7 packages here
RUN conda create -n py27 python=2.7 anaconda seaborn flake8 -y && \
    pip install influxdb && \
    conda clean -i -l -t -y
    
# Install R 
RUN apt-get update && \
    apt-get install r-base r-cran-rodbc -y && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
    
# Install RStudio-Server
RUN apt-get update && \
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
RUN usermod -l rstudio docker \
  && usermod -m -d /home/rstudio rstudio \
  && groupmod -n rstudio docker \
  && echo '"\e[5~": history-search-backward' >> /etc/inputrc \
  && echo '"\e[6~": history-search-backward' >> /etc/inputrc \
  && echo "rstudio:rstudio" | chpasswd

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

# Start Jupyter at container start
CMD ["startup.sh"]

# Copy Jupyter start script into the container.
COPY start-notebook.sh /usr/local/bin/
COPY start-r-server.sh /usr/local/bin/

# Copy startup script into the container.
COPY startup.sh /usr/local/bin/

# Fix permissions
RUN chmod +x /usr/local/bin/start-notebook.sh && chmod +x /usr/local/bin/startup.sh && chmod +x /usr/local/bin/start-r-server.sh
