FROM ruby:2.7.1

LABEL maintainer="ocsarpo22@gmail.com"

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
    nodejs \
    yarn

COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app
RUN bundle install    

COPY . /usr/src/app/

# RUN rails webpacker:install # 볼륨 마운팅 후에 로컬에서 실행하였음

CMD ["bin/rails", "s", "-b", "0.0.0.0"]