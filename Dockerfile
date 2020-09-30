FROM ruby:2.7.1

LABEL maintainer="ocsarpo22@gmail.com"

# apt가 https기반의 sources로 일하도록 함
RUN apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
    apt-transport-https

# 최신 버전의 Node를 설치할 것을 보장한다.
# # See https://github.com/yarnpkg/yarn/issues/2888
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

# Ensure latest packages for Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | \ 
    tee /etc/apt/sources.list.d/yarn.list


RUN apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
    nodejs \
    yarn

COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app

ENV BUNDLE_PATH /gems

RUN bundle install    

COPY . /usr/src/app/

CMD ["bin/rails", "s", "-b", "0.0.0.0"]