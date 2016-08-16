FROM kaggle/python:latest
MAINTAINER Florian Geigl <florian.geigl@gmail.com>

# install graph-tool
# RUN pip install pycairo
RUN apt-get install python-software-properties &&\
    add-apt-repository ppa:boost-latest/ppa && \
    apt-get update && \
    apt-get install -y libboost-all-dev expat libcgal-dev libsparsehash-dev
RUN cd /usr/local/src && git clone https://git.skewed.de/count0/graph-tool.git && \
    git fetch --tags && \
    latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag && \
    cd graph-tool && \
    ./configure
    #make && \
    #make install

RUN pip install tqdm
