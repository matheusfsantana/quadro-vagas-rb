ARG RUBY_VERSION=3.4.2
ARG DISTRO=bullseye

FROM ruby:${RUBY_VERSION}-slim-${DISTRO}

RUN apt update && apt install -y --no-install-recommends \
    chromium \
    chromium-driver \
    build-essential \
    libpq-dev \
    libyaml-dev \
    libvips42

WORKDIR /home/app/web

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . . 

RUN rails assets:precompile

CMD ["bin/rails", "server", "-p", "3000", "-b", "0.0.0.0"]

EXPOSE 3000