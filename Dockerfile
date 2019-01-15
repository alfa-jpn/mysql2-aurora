FROM ruby:2.6.0-alpine3.8

# Create application directory.
RUN mkdir /app
WORKDIR /app

# Install package
RUN apk upgrade && apk add --update build-base git linux-headers libxml2-dev libxslt-dev mariadb-dev ruby-dev tzdata yaml-dev zlib-dev

# Deploy application
ADD . /app

# Install gem
RUN bundle install

# Run test
CMD ["/app/bin/test"]
