FROM cimg/ruby:3.3.6-node

USER root

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=/app/bin:$PATH \
    _JAVA_OPTIONS="-Djava.awt.headless=true"

RUN apt-get update && apt-get install -y openjdk-17-jdk

WORKDIR /app

COPY . /app

RUN gem install bundler

RUN bundle install

RUN npm install

CMD ["bin/delaware", "version"]
