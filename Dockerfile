FROM kaggle/python:latest
MAINTAINER Florian Geigl <florian.geigl@gmail.com>

# install graph-tool
# RUN pip install pycairo
RUN apt-get update && \
    apt-get install -y libboost-all-dev expat libcgal-dev libsparsehash-dev
RUN cd /usr/local/src && \
    git clone https://github.com/count0/graph-tool.git && \
    cd graph-tool && \
    git fetch --tags && \
    latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag && \
    ./configure
    #make && \
    #make install

RUN pip install tqdm
