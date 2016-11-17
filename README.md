# Massive Data Science Image
Dockerfile containing lots of tools for Data Science (python2/3, Julia, jupyter, R, R-Studio-Server...)

# Run
```
docker run --rm -i -t -p 8888:8888 -p 8787:8787 -p 2222:22 -v "${pwd}:/tmp/notebooks_tmp/" \ 
--name dsdocker floriangeigl/datascience
```
