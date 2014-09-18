# SprintApp web application Docker image
#
# VERSION       1.0

# ~~~~ Image base ~~~~
FROM zedtux/ruby-1.9.3
MAINTAINER zedtux, zedtux@zedroot.org

ENV POSTGRESQL_VERSION 9.3
ENV USERNAME sprintapp
ENV DB_PASSWORD ''
ENV DATABASE_NAME 'sprint_app_development'

# ~~~~ PostgreSQL ~~~~
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get install -y python-software-properties \
  software-properties-common \
  postgresql-$POSTGRESQL_VERSION \
  postgresql-client-$POSTGRESQL_VERSION \
  postgresql-contrib-$POSTGRESQL_VERSION \
  git \
  libpq-dev \
  build-essential

# Login as postgres user
USER postgres
# Enable listening on all network devises
RUN sed -i -e "s/.*listen_addresses.*/listen_addresses = '*'/g" /etc/postgresql/$POSTGRESQL_VERSION/main/postgresql.conf
# Use md5 authentication mechanism for all IPv4 connections
RUN echo "host\tall\tall\t0.0.0.0/0\tmd5" >> /etc/postgresql/$POSTGRESQL_VERSION/main/pg_hba.conf
RUN echo "local\tall\tall\t\tmd5" >> /etc/postgresql/$POSTGRESQL_VERSION/main/pg_hba.conf
# Start PostgreSQL and update postgres user in order to remove the password
RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER $USERNAME WITH ENCRYPTED PASSWORD '$DB_PASSWORD';" && \
    createdb --owner=$USERNAME --template=template0 --encoding=UTF8 $DATABASE_NAME

USER root

# ~~~~ Rails Preparation ~~~~
# Global gem configuration
RUN touch ~/.gemrc && echo "gem: --no-ri --no-rdoc" >> ~/.gemrc
# Rubygems
RUN gem install rubygems-update
RUN update_rubygems
# Bundler
RUN gem install bundler
# Copy the Gemfile and Gemfile.lock into the image.
# Temporarily set the working directory to where they are.
RUN mkdir -p /sprintapp/
WORKDIR /sprintapp/
# Import the source code (look at the .dockerignore file)
ADD . /sprintapp/
# Copy default database config file
RUN cp config/database.yml.sample config/database.yml

RUN bundle config build.eventmachine "--with-cflags=\"-O2 -pipe -march=native -w\""
RUN bundle config build.thin "--with-cflags=\"-O2 -pipe -march=native -w\""
RUN bundle --deployment --without development test

EXPOSE 3000

# Run the Rails server
ENTRYPOINT /etc/init.d/postgresql start && \
  bundle exec rake db:setup && \
  bundle exec rails server thin
