# start from base os
FROM ubuntu:14.04
MAINTAINER Prakhar Srivastav <prakhar@prakhar.me>

# install system-wide deps for python and node
# using 'apt-get' to install
#the yqq flag is used to supress output and assumes "Yes" to all th prompts
#we also create a symbolic loink for the node binary to deal with backward compatibility issues...
RUN apt-get -yqq update
RUN apt-get -yqq install python-pip python-dev
RUN apt-get -yqq install nodejs npm
RUN ln -s /usr/bin/nodejs /usr/bin/node

# copy our application code into a new volume in the container
# this is where our code will reside
# we also set this as our working directory
# so that the following commands will be run in the context of this location...
ADD flask-app /opt/flask-app
WORKDIR /opt/flask-app

# fetch app specific deps
# now that our system-wide dependencies are installed,
# we can install app-specific ones

# first we tackle node by installing all the packages and running a build script defined in package.json...
RUN npm install
RUN npm run build

#read requirements.txt and pip install those
RUN pip install -r requirements.txt

# expose port
EXPOSE 5000

# start app
CMD [ "python", "./app.py" ]

# now we can build the image and run the container with:
# ``` docker build -t caseydailey/foodtrucks-web . ```

#### note ###

# while this build the flask-app ocntainer, we are not able to connect to the elastic-search container until we network them.

# to do this, need to know the ip for the elastic search container:

# ``` docker network inspect bridge ```
# now we can see which IP the elastic search container has been alloted, then we can run the food-trucks container and curl this IP:

# ``` docker run -it --rm prakhar1989/foodtrucks-web ```

# after getting "curl" with:

# ``` apt-get -yqq install curl ```

# now we can:

# ``` curl 172.17.0.2:9200 ``` 

# apparently this is a work around. while the containers can now talk to each other, using the default 'bridge' network is not secure and we don't want to have to come back and cofigure the /etc/hosts file everytime the IP for es changes

# do we're goin to have to create our own network:

#  ``` docker network create foodtrucks ```

# this creates a new 'bridge network'
# now stop the elastic search container:

# ```  docker stop 6be7d3b42e7b ``` (the id of the elasticsearch container)

#then we can run: 

# ``` docker run -dp 9200:9200 --net foodtrucks --name es elasticsearch ```

# this does the same thing as earlier but this time we gave our ES container a name 'es' 

# and when we run:
# ``` docker run -it --rm --net foodtrucks prakhar1989/foodtrucks-web bash ```

# we can ```curl es:9200``` and talk to our es container from the flask app.

# now we can run it for real:

# ``` docker run -d --net foodtrucks -p 5000:5000 --name foodtrucks-web caseydailey/foodtrucks-web ```

# and when we docker ps we see both running!

to re-cap: this is all it took, commands-wise to get running:

#!/bin/bash

# build the flask container
# ```docker build -t caseydailey/foodtrucks-web .```

# create the network
# ```docker network create foodtrucks```

# start the ES container
```docker run -d --net foodtrucks -p 9200:9200 -p 9300:9300 --name # ```es elasticsearch

# start the flask app container
```docker run -d --net foodtrucks -p 5000:5000 --name # ```foodtrucks-web caseydailey/foodtrucks-web

