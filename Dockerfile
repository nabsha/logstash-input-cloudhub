FROM docker.elastic.co/elasticsearch/elasticsearch
COPY logstash-input-cloudhub-1.0.0.gem /logstash-input-cloudhub.gem
RUN  logstash-plugin install /logstash-input-cloudhub.gem
