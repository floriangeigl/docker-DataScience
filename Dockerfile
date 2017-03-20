FROM kaggle/python:latest
MAINTAINER Florian Geigl <florian.geigl@gmail.com>

COPY layer_cleanup.sh /usr/local/bin/

# Install apt stuff, graph-tool, setup ssh, set timezone and update conda
RUN chmod +x /usr/local/bin/layer_cleanup.sh && \
    mkdir -p /data/ && \
    echo "Europe/Vienna" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata && \
    # cp /etc/timezone /tz/ && cp /etc/localtime /tz/ && \
    apt-key update && apt-get update && \
    # add more packages here \
    apt-get install bash-completion vim screen htop less git mercurial subversion openssh-server supervisor xvfb locate \
        fonts-texgyre gsfonts libcairo2 libjpeg62-turbo libpango-1.0-0 libpangocairo-1.0-0 libpng12-0 libtiff5 dos2unix \
        unixodbc-dev unixodbc libxtst6 tdsodbc freetds-dev \
        -y --no-install-recommends && \ 
    # install graph-tool
    # apt-key adv --keyserver pool.sks-keyservers.net --recv-key 612DEFB798507F25 && \
    # touch /etc/apt/sources.list.d/graph-tool.list && \
    # echo 'deb http://downloads.skewed.de/apt/stretch stretch main' >> /etc/apt/sources.list.d/graph-tool.list && \
    # echo 'deb-src http://downloads.skewed.de/apt/stretch stretch main' >> /etc/apt/sources.list.d/graph-tool.list && \
    # apt-get update && apt-get install -y --no-install-recommends python3-graph-tool && \
    # ln -s /usr/lib/python3/dist-packages/graph_tool $(find /opt/conda/lib/python* -type d -name "site-packages")/graph_tool && \
    # setup ssh
    mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    # update conda
    conda install conda-build pip -y && \
    conda update conda conda-env conda-build pip -y && \
    layer_cleanup.sh

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
    julia /tmp/package_install.jl 2>&1 | tee /var/log/julia_pkg_installs.log  && \
    # cleanup
    layer_cleanup.sh

# Install python2.7 for conda
# add python2.7 packages here
RUN conda create -n py27 python=2.7 anaconda seaborn flake8 -y && \
    conda clean -i -l -t -y && \
    pip install influxdb && \
    layer_cleanup.sh
    
# Install R, R-packages and r-server (use conda install r-cran-* packages or add your packages to package_install.r)
COPY package_install.r Rprofile odbcinst.ini /tmp/
RUN apt-key update && apt-get update && \
    conda install r r-base r-essentials r-recommended -c r -y && \
    cat /tmp/Rprofile >> /root/.Rprofile && \
    conda install r-ggplot2 r-gtools r-xml r-xml2 r-plyr r-rcurl \
      r-data.table r-knitr r-dplyr r-rjsonio r-nmf r-igraph r-futile.logger \
      r-zoo r-gdata r-catools r-lmtest r-gplots r-htmltools r-htmlwidgets r-dt \
      -c bioconda -c r -c BioBuilds -c conda-forge -y && \
    echo "Install packages from package_install.r..." && \
    /opt/conda/bin/Rscript /tmp/package_install.r 2>&1 | tee /var/log/r_pkg_installs.log && \
    # install r-server
    useradd -m rstudio && \
    echo "rstudio:rstudio" | chpasswd && \
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
    # configure FreeTDS Driver (r-odbc sql driver)
    cat /tmp/odbcinst.ini >> /etc/odbcinst.ini && \
    wget https://github.com/jgm/pandoc-templates/archive/1.15.0.6.tar.gz && \
    mkdir -p /opt/pandoc/templates && tar zxf 1.15.0.6.tar.gz && \
    cp -r pandoc-templates*/* /opt/pandoc/templates && rm -rf pandoc-templates* && \
    mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates && \
    # cleanup
    layer_cleanup.sh
        
# Install conda/pip python3 libs and notebook extensions
# waiting for python3 support: librabbitmq
COPY jupyter_custom.js py_default_imports.js odbcinst.ini /tmp/
RUN conda config --add channels conda-forge && \
    conda install cairomm jupyterlab flake8 jupyter_contrib_nbextensions yapf ipywidgets pandasql \
    dask distributed pyodbc pymc3 geopy hdf5 h5py ffmpeg autopep8 -y && \
    jupyter serverextension enable --py jupyterlab --sys-prefix && \
    jupyter contrib nbextension install --sys-prefix && \
    git clone https://github.com/Calysto/notebook-extensions.git /opt/calysto_notebook-extensions && \
        cd /opt/calysto_notebook-extensions && jupyter nbextension install calysto --sys-prefix && \
    echo "codefolding/main code_font_size/code_font_size toc2/main autosavetime/main \
        code_prettify/autopep8 scratchpad/main search-replace/main comment-uncomment/main select_keymap/main \
        spellchecker/main toggle_all_line_numbers/main chrome-clipboard/main execute_time/ExecuteTime \
        notify/notify tree-filter/index printview/main table_beautifier/main highlighter/highlighter \
        navigation-hotkeys/main addbefore/main snippets_menu/main datestamper/main help_panel/help_panel \
        # calysto
        calysto/cell-tools/main calysto/document-tools/main" \
        # install cmd
            | xargs -n1 jupyter nbextension enable && \
        jupyter nbextension enable --py --sys-prefix widgetsnbextension && \
    # install custom jss & default imports extension
    mkdir -p /root/.jupyter/custom/ && \
    cat /tmp/jupyter_custom.js >> /root/.jupyter/custom/custom.js && \
    mkdir -p /tmp/py_default_imports/ && \
    mv /tmp/py_default_imports.js /tmp/py_default_imports/main.js && \
    jupyter nbextension install --sys-prefix /tmp/py_default_imports && \
    jupyter nbextension enable --sys-prefix py_default_imports/main && \
    # currently not working: limit_output/main hinterland/hinterland
    pip install tabulate ftfy pyflux cookiecutter segtok gensim textblob pandas-ply influxdb bpython implicit \
        jupyterthemes cassandra-driver sklearn-pandas geocoder readchar lightfm scikit-optimize \
        matplotlib-venn pathos pika tpot pymssql && \
        # pycairo
    #git clone https://github.com/hyperopt/hyperopt-sklearn.git /tmp/hyperopt-sklearn && \
    #    cd /tmp/hyperopt-sklearn && pip install -e . && cd - && \
    # set default notebook theme, font etc.
    jt -t grade3 -f sourcemed -T -N -cellw 1200 && \
    # disable notebook authentication
    echo "c.NotebookApp.token = ''\nc.NotebookApp.password = ''\n" >> /root/.jupyter/jupyter_notebook_config.py && \
    # set freetds driver for pyodbc
    cat /tmp/odbcinst.ini >> /opt/conda/etc/odbcinst.ini && \
    layer_cleanup.sh
    
# Copy some start script into the container.
COPY export_environment.sh \
    init.sh \
    /usr/local/bin/

# Fix permissions and bash-completion
COPY bash_completion_fix.sh /tmp/
RUN chmod +x /usr/local/bin/init.sh && \
    chmod +x /usr/local/bin/export_environment.sh && \
    cat /tmp/bash_completion_fix.sh >> /etc/bash.bashrc && \ 
    echo "if [ -f /etc/bash_completion ]; then" >> ~/.bash_profile && \
    echo "  . /etc/bash_completion" >> ~/.bash_profile && \
    echo "fi" >> ~/.bash_profile && \
    layer_cleanup.sh

# Expose jupyter notebook, jupyter labs, r-studio-server and ss port.
EXPOSE 8888 8889 8787 22

# Define mount volumne
VOLUME ["/data"]

# copy supervisor conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start all scripts
ENTRYPOINT ["init.sh"]
CMD [""]
