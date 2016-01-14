FROM ruby:2.3

MAINTAINER Marvin Caspar <marvin.caspar@gmail.com>

# Update system
RUN apt-get update -qq

# Install dependencies
RUN apt-get install -y nodejs libmysqlclient-dev libsqlite3-dev build-essential

# Create app folder
RUN mkdir -p /var/www/html

# Set working directory
WORKDIR /var/www/html

RUN gem install rails -v 5.0.0.beta1

# set bundle path
RUN bundle config path vendor/bundle
