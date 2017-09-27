FROM docker.elastic.co/logstash/logstash:5.6.0
MAINTAINER Leonardo Mello Gaona

COPY logstash-input-cloudhub-1.3.1.gem /logstash-input-cloudhub.gem
RUN logstash-plugin install /logstash-input-cloudhub.gem
