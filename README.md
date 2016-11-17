# Massive Data Science Image
Dockerfile containing lots of tools for Data Science (python2/3, Julia, jupyter, R, R-Studio-Server...)

# Run
```
docker run --rm -i -t -p 8888:8888 -p 8787:8787 -p 2222:22 -v "${pwd}:/tmp/notebooks_tmp/" --name dsdocker floriangeigl/datascience
```

# Windows Shortcut
Open a powershell and open your profile-file using the follwing command.
´´´
notepad $PROFILE
´´´
paste the following lines into the notepad and save the file.
´´´
function dsdocker {
docker run --rm -i -t -p 8888:8888 -p 8787:8787 -p 2222:22 -v "${pwd}:/tmp/notebooks_tmp/" --name dsdocker floriangeigl/datascience
}
´´´
No you can simple fire up a Data Science container by typing ´´´dsdocker´´´ in your powershell. This will also mount the working directory into /data/ in the docker container.
