FROM debian:wheezy
MAINTAINER Viktor Petersson <vpetersson@wireload.net>

RUN apt-get update && \
    apt-get -y install git-core net-tools python-pip python-netifaces python-simplejson python-imaging python-dev sqlite3 && \
    apt-get clean

# Install Python requirements
ADD requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# Create runtime user
RUN useradd pi

# Install config file and file structure
RUN mkdir -p /home/pi/.lynda /home/pi/lynda /home/pi/lynda_assets
COPY misc/screenly.conf /home/pi/.lynda/screenly.conf
RUN chown -R pi:pi /home/pi

# Copy in code base
COPY . /home/pi/lynda

USER pi
WORKDIR /home/pi/lynda

EXPOSE 8080
VOLUME /home/pi/lynda

CMD python server.py
