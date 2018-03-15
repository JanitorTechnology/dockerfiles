FROM janx/ubuntu-dev

# Get updates if there are any
RUN sudo apt-get update -q \
  && sudo apt-get upgrade -qy \
  && sudo apt-get install -qy

# Get source code
RUN git clone https://github.com/dspace/dspace-angular /home/user/dspace-angular
WORKDIR /home/user/dspace-angular

RUN yarn run global \
  && yarn install

# Add Janitor configurations
COPY janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json

# Configure the IDEs to use DSpace's source directory as workplace
ENV WORKPLACE /home/user/dspace/

# For Angular
EXPOSE 3000
