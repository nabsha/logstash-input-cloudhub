FROM docker.elastic.co/logstash/logstash-oss:6.5.4
MAINTAINER Leonardo Mello Gaona
COPY logstash-input-cloudhub-2.0.1.gem /logstash-input-cloudhub.gem
RUN logstash-plugin install /logstash-input-cloudhub.gem
