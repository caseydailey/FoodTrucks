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

# now we can build the image and run the container
