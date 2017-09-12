# encoding: utf-8

require "net/http"
require "json"

class CloudhubClient
  def initialize logger, username, password, organization_id, environment_id, events_per_call
    @logger = logger
    @username = username
    @password = password
    @organization_id = organization_id
    @environment_id = environment_id
    @events_per_call = events_per_call
  end

  # Return an OAuth 2.0 bearer token to be used on subsequent API calls
  def token
    uri = URI.parse('https://anypoint.mulesoft.com/accounts/login')

    client = Net::HTTP.new(uri.host, uri.port)
    client.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = URI.encode_www_form({
      "username" => @username,
      "password" => @password
    })

    response = client.request(request)
    access_token = JSON.parse(response.body)['access_token']
    @logger.info('Access token: ' + access_token)
    return access_token
  end

  # Returns all applications for a given organization and environment. Useful properties:
  # { "domain"=>"my_name", "fullDomain"=>"my_name.eu.cloudhub.io", ... }
  def apps organization_id, environment_id, cached_token=token
    uri = URI.parse("https://anypoint.mulesoft.com/cloudhub/api/v2/applications")
    client = Net::HTTP.new(uri.host, uri.port)
    client.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)
    request.add_field("Authorization", "Bearer #{cached_token}")
    request.add_field("X-ANYPNT-ENV-ID", environment_id)
    request.add_field("X-ANYPNT-ORG-ID", organization_id)

    response = client.request(request)

    return JSON.parse(response.body)
  end

  def logs startTime, environment_id, application, cached_token=token
    uri = URI.parse("https://anypoint.mulesoft.com/cloudhub/api/v2/applications/#{application}/logs")

    client = Net::HTTP.new(uri.host, uri.port, @proxy_host, @proxy_port, @proxy_username, @proxy_password)
    client.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request.add_field("Authorization", "Bearer #{cached_token}")
    request.content_type = 'application/json'
    request.body = JSON.generate({
      :startTime => startTime,
      :endTime => java.lang.Long::MAX_VALUE,
      :limit => @events_per_call,
      :descending => false
    })
    request.add_field("X-ANYPNT-ENV-ID", environment_id)
    retries = 10
    while retries > 0
      response = client.request(request)
      begin
        parsed_logs = JSON.parse(response.body)
        return parsed_logs
      rescue
        retries -= 1
        if (retries == 0)
          @logger.error("Can't parse logs: " + response.body)
        end
        Stud.stoppable_sleep(5)
      end
    end
    return []
  end
end
