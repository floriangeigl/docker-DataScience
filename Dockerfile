FROM kaggle/python:latest
MAINTAINER Florian Geigl <florian.geigl@gmail.com>

# install graph-tool
RUN echo "deb http://ftp.debian.org/debian/ stretch main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends libtool automake build-essential libboost-all-dev expat libcgal-dev libsparsehash-dev && \
    apt autoremove -y && apt clean
RUN conda install pycairo cairomm libiconv -c conda-forge -c floriangeigl -y && \
    conda clean -i -l -t -y
RUN cd /usr/local/src && \
    git clone https://github.com/count0/graph-tool.git && \
    cd graph-tool && \
    git fetch --tags && \
    latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag && \
    ./autogen.sh && \
    ./configure --prefix=/opt/conda/include/ CPPFLAGS=-I$(find /opt/conda/pkgs -regextype posix-extended -regex ".*py[0-9]?cairo.*/include" -type d | head -1) --enable-silent-rules --enable-openmp PKG_CONFIG_PATH=/opt/conda/lib/pkgconfig/ && \
    echo "Use $(nproc) cpus to build graph-tool" && \
    make -j $(nproc) && \
    make install && \
    cd ../ && \
    rm -r graph-tool
RUN pip install tabulate ftfy pyflux cookiecutter
