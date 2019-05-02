FROM gcr.io/kaggle-images/python
LABEL maintainer="florian.geigl@gmail.com"

COPY layer_cleanup.sh /usr/local/bin/
# pre-req to find fastest apt mirror
RUN chmod +x /usr/local/bin/layer_cleanup.sh && \
    mkdir -p /data/ && \
    apt-key update && apt-get update && \
    apt-get install netselect-apt -y --no-install-recommends --no-upgrade && \
    # echo "Europe/Vienna" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata && \
    # cp /etc/timezone /tz/ && cp /etc/localtime /tz/ && \
    layer_cleanup.sh

# Define mount volume
VOLUME ["/data", "/var/log"]

# Install apt stuff, graph-tool, setup ssh, set timezone and update conda
RUN cat /etc/apt/sources.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list && \
    echo "deb http://deb.debian.org/debian stretch-backports main" | tee /etc/apt/sources.list.d/stretch-backports.list && \
    # find fastest apt mirror
    # netselect-apt && \
    # mv ./sources.list /etc/apt/sources.list && \
    cat /etc/apt/sources.list && \
    apt-key update && apt-get update && \
    # add more packages here \
    apt-get install bash-completion vim-tiny screen htop less git openssh-server supervisor dos2unix \
        mongodb-org-shell mongodb-org-tools \
        -y --no-install-recommends --no-upgrade && \
    # setup ssh
    mkdir /var/run/sshd && \
    echo 'root:datascience' | chpasswd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    conda config --add channels conda-forge && \
    # fix ldconfig (libstdc++.so.6: version `CXXABI_1.3.9' not found)
    echo "/opt/conda/lib" > /etc/ld.so.conf && \
    ldconfig && \
    layer_cleanup.sh
       
# Install conda/pip python3 libs and notebook extensions
COPY jupyter_custom.js py_default_imports.js /tmp/
RUN pip install --upgrade pip && \
    conda install libev jupyterlab flake8 jupyter_contrib_nbextensions yapf ipywidgets pandasql \
        dask distributed pyodbc pymc3 geopy hdf5 h5py ffmpeg autopep8 datashader bqplot pyspark \
        bokeh python-snappy lz4 gxx_linux-64 pika pathos pymssql tabulate gensim textblob \
        geocoder scikit-optimize matplotlib-venn dask-searchcv jupyterthemes \
        libarchive pyhive elasticsearch-dsl libpng libtiff jupyter_latex_envs tmux \
        kafka-python scikit-plot fire pdir2 h2o turbodbc \
        -y --no-channel-priority && \ 
        # --no-update-deps
    conda install -c damianavila82 rise -y && \
    jupyter serverextension enable --py jupyterlab --sys-prefix && \
    jupyter contrib nbextension install --sys-prefix && \
    git clone https://github.com/Calysto/notebook-extensions.git /opt/calysto_notebook-extensions && \
        cd /opt/calysto_notebook-extensions && jupyter nbextension install calysto --sys-prefix && \
    echo "codefolding/main code_font_size/code_font_size toc2/main autosavetime/main \
        scratchpad/main search-replace/main comment-uncomment/main select_keymap/main \
        spellchecker/main toggle_all_line_numbers/main chrome-clipboard/main execute_time/ExecuteTime \
        notify/notify tree-filter/index printview/main table_beautifier/main highlighter/highlighter \
        navigation-hotkeys/main addbefore/main snippets_menu/main datestamper/main help_panel/help_panel \
        hide_header/main freeze/main limit_output/main varInspector/main \
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
    pip install ftfy scales pyflux cookiecutter segtok pandas-ply influxdb bpython implicit \
        cassandra-driver sklearn-pandas readchar lightfm python-tds tpot dask-ec2 pylzma \
        hdfs cqlsh tables xgbfir pygelf featexp pycm awscli lime && \
    # set default notebook theme, font etc.
    jt -t grade3 -f sourcemed -T -N -cellw 1200 && \
    # disable notebook authentication
    echo "c.NotebookApp.token = ''\nc.NotebookApp.password = ''\n" >> /root/.jupyter/jupyter_notebook_config.py && \
    # install graph-tool
    # conda install gtk3 -c pkgw-forge --no-channel-priority -y && \
    # conda install pygobject --no-channel-priority -y && \
    # conda install graph-tool -c ostrokach-forge --no-channel-priority -y && \
    # conda update jupyter notebook jupyter_core --no-channel-priority  -y && \
    # tmp fixes for tensorflow
    # pip install --upgrade pip && \
    # pip install --upgrade tensorflow && \
    layer_cleanup.sh

# Copy some start script into the container.
COPY export_environment.sh \
    init.sh \
    /usr/local/bin/

# Fix permissions and bash-completion
COPY append2bashprofile.sh \
    append2bashrc.sh \
    /tmp/

RUN chmod +x /usr/local/bin/init.sh /usr/local/bin/export_environment.sh && \
    cat /tmp/append2bashrc.sh >> /etc/bash.bashrc && \
    cat /tmp/append2bashrc.sh >> ~/.bashrc && \
    cat /tmp/append2bashprofile.sh >> ~/.bash_profile && \
    layer_cleanup.sh

# Expose jupyter notebook (8888), jupyter labs (8889), ss port (22) and supervisor web interface (9001).
EXPOSE 8888 8889 22 9001

# copy supervisor conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start all scripts
ENTRYPOINT ["init.sh"]
CMD [""]

# test basic notebook
COPY tests/py3_test_notebook.ipynb /tmp/
RUN cd /tmp/ && \
    jupyter nbconvert --ExecutePreprocessor.timeout=600 --to notebook --execute py3_test_notebook.ipynb && \
    layer_cleanup.sh
