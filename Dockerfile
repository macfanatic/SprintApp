# SprintApp web application Docker image
#
# VERSION       1.0

# ~~~~ Image base ~~~~
FROM litaio/ruby
MAINTAINER zedtux, zedtux@zedroot.org


# ~~~~ OS Maintenance ~~~~
# Keep up-to-date the container OS
RUN apt-get update && apt-get upgrade -y
# Install required header files for PostgreSQL in order to install pg gem
RUN apt-get install -y libpq-dev


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
RUN mkdir -p /sprintapp/bundler/
ADD Gemfile /sprintapp/bundler/Gemfile
ADD Gemfile.lock /sprintapp/bundler/Gemfile.lock
WORKDIR /sprintapp/bundler/
RUN bundle --deployment --without development test
# ~~~~ Sources Preparation ~~~~
# Prepare application source folder
RUN mkdir /sprintapp/application/
WORKDIR /sprintapp/application/
# Import the source code (look at the .dockerignore file)
ADD . /sprintapp/application/

RUN bundle exec rake assets:precompile RAILS_ENV=production

EXPOSE 3000

# Run the Rails server
# CMD bundle exec rake db:setup
ENTRYPOINT bundle exec rails server thin
