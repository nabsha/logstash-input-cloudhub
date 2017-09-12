FROM logstash:5.5.2
COPY logstash-input-cloudhub-1.1.0.gem /logstash-input-cloudhub.gem
RUN logstash-plugin install /logstash-input-cloudhub.gem
