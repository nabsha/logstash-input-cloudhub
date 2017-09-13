# Logstash CloudHub input plugin

## Building your image locally
```sh
export CLOUDHUB_USERNAME=YOUR_USERNAME
export CLOUDHUB_PASSWORD=YOUR_PASSWORD
export CLOUDHUB_ORGANIZATION_ID=CLOUDHUB_ORGANIZATION_ID
export ENV_NAME=ENVIROMENT_NAME
export CLOUDHUB_ENV_ID=ENVIRONMENT_ID
docker-compose build
```

## Running a container
```sh
docker-compose up
```

## Parameters

###CLOUDHUB_USERNAME
Your cloudhub management username

###CLOUDHUB_PASSWORD
Your cloudhub management password

###CLOUDHUB_ORGANIZATION_ID
The anypoint platform id for your organization (ITLabs, Commercial etc. Check confluence for more details under Anypoint Organizations article)

###ENV_NAME
The environment name to be set on logstash events. This has no relationship with CloudHub and accepts any value. The default value is `Development`

###CLOUDHUB_ENV_ID
The anypoint platform id for the desired environment (Check confluence for more details under Anypoint Organizations article. Each environment has a different id per organization)
