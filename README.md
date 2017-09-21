# Logstash CloudHub input plugin

## Running the image
```sh
export CLOUDHUB_USERNAME=YOUR_USERNAME
export CLOUDHUB_PASSWORD=YOUR_PASSWORD
export CLOUDHUB_ORGANIZATION_ID=CLOUDHUB_ORGANIZATION_ID
export CLOUDHUB_ENV_NAME=ENVIROMENT_NAME
docker run -it --rm --name cloudlog sciensa/logstash-cloudhub:1.3.2 logstash --debug -e 'input { cloudhub { username => "${CLOUDHUB_USERNAME}" password => ${CLOUDHUB_PASSWORD}" organization_id => "${CLOUDHUB_ORGANIZATION_ID}" environment_name => "${CLOUDHUB_ENV_NAME}" } } output { stdout {} }'
```

## Parameters

###CLOUDHUB_USERNAME
Your cloudhub management username

###CLOUDHUB_PASSWORD
Your cloudhub management password

###CLOUDHUB_ORGANIZATION_ID
The anypoint platform id for your organization (ITLabs, Commercial etc. Check confluence for more details under Anypoint Organizations article)

###CLOUDHUB_ENV_NAME
The environment name to be set on logstash events. It must match an environment under the organization whose id was provided. The default value is `Development`
