FROM janitortechnology/ubuntu-dev

# Get source code
RUN git clone https://github.com/dspace/dspace-angular /home/user/dspace-angular/
WORKDIR /home/user/dspace-angular/

# Add server configuration
COPY environment.prod.js /home/user/dspace-angular/config/
RUN sudo chown user:user /home/user/dspace-angular/config/environment.prod.js

# Install dependencies
RUN yarn run global \
  && yarn install \
  && yarn prestart

# Add Janitor configurations
COPY janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json

# Configure the IDEs to use Janitor's source directory as workspace.
ENV WORKSPACE /home/user/dspace-angular/

# For DSpace Angular
EXPOSE 3000
