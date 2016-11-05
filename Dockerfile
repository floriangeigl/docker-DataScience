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
    apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install python2.7 for conda
RUN conda create -n py27 python=2.7 anaconda -y && \
    conda clean -i -l -t -y
    
# Install R for conda
RUN conda create -n r-env -c r r-essentials -y && \
    source activate r-env && \
    conda install DiagrammeR mefa gridSVG rgeos rgdal rARPACK Amelia prevR -y && \
    source deactivate r-env && \
    conda clean -i -l -t -y

# Install other apt stuff
RUN apt-get update && \
    apt-get install bash-completion vim screen htop less git mercurial subversion \ 
    # add more packages here \
    -y --no-install-recommends && \ 
    apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install conda libs
RUN conda install pycairo cairomm libiconv jupyterlab -c conda-forge -c floriangeigl -y && \
    conda clean -i -l -t -y
# conda update -y conda conda-build pip && \

# Install pip libs
RUN pip install tabulate ftfy pyflux cookiecutter segtok gensim textblob pandas-ply
# python -m textblob.download_corpora
