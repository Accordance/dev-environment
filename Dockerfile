FROM ruby:2.1.2
MAINTAINER Igor Moochnick <igor@igroshare.com>

RUN mkdir /opt/dev
WORKDIR /opt/dev
ADD rake_tasks rake_tasks
ADD container_templates container_templates
ADD consul_policies consul_policies
ADD Rakefile Rakefile
ADD Gemfile Gemfile
ADD consul_token.development consul_token.development
WORKDIR /opt
RUN curl -o data-source.tar.gz https://codeload.github.com/Accordance/data-source/tar.gz/master
RUN mkdir /opt/data-source
RUN tar -xzf data-source.tar.gz -C data-source --strip-components=1
WORKDIR /opt/data-source
RUN bundle install
WORKDIR /opt/dev

ENTRYPOINT ["rake"]
