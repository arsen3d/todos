#FROM meteorhacks/meteord:onbuild
#FROM ulexus/meteor:latest

FROM ubuntu:14.04
MAINTAINER Stephen Pope, spope@projectricochet.com


RUN mkdir /home/meteorapp
WORKDIR /home/meteorapp
ADD . ./meteorapp
RUN apt-get update -q && apt-get clean
RUN apt-get install curl -y \
  && (curl https://install.meteor.com/ | sh) \
  && cd /home/meteorapp/meteorapp \
  && meteor build ../build --directory \
  && cd /home/meteorapp/meteorapp/build/bundle \
  && bash -c 'curl "https://nodejs.org/dist/$(<.node_version.txt> /home/meteorapp/meteorapp/build/required-node-linux-x64.tar.gz' \
  && cd /usr/local && tar --strip-components 1 -xzf /home/meteorapp/meteorapp/build/required-node-linux-x64.tar.gz \
  && rm /home/meteorapp/meteorapp/build/required-node-linux-x64.tar.gz \
  && cd /home/meteorapp/meteorapp/build/bundle/programs/server \
  && npm install \
  && rm /usr/local/bin/meteor \
  && rm -rf ~/.meteor \
  && apt-get --purge autoremove curl -y

RUN npm install -g forever

EXPOSE 3000
ENV PORT 3000

CMD ["forever", "--minUptime", "1000", "--spinSleepTime", "1000", "meteorapp/build/bundle/main.js"]