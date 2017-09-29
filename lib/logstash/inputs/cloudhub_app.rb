# encoding: utf-8

require_relative 'cloudhub_client'

require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "fileutils"
require "socket"
require "date"

# This input plugin reads application data from CloudHub
class LogStash::Inputs::Cloudhub < LogStash::Inputs::Base
  config_name "cloudhub_app"

  # Anypoint user name
  config :username, :validate => :string
  # Anypoint password
  config :password, :validate => :string
  # Default codec
  default :codec, "plain"
  # Interval (in seconds) between two log fetches.
  # (End of previous fetch to start of next fetch)
  # Default value: 600 (10 minutes)
  config :interval, :validate => :number, :default => 600

  public
  def register
    @host = Socket.gethostname
  end

  def run(queue)
    api = CloudhubClient.new(@logger, @username, @password)

    while !stop?
      # get the token once per main loop (more efficient than fetching it for each API call)
      token = api.token()

      # gets the profile data to find the organization ids
      profile = api.profile(token)
      organization_ids = profile['user']['organization']['subOrganizationIds']
      # push the main organization to the array
      organization_ids << profile['user']['organization']['id']

      # iterates all organizations to fetch environments
      organization_ids.each do |organization_id|
        organization = api.organization(organization_id, token)
        organization_name = organization['name']
        environments = organization['environments']

        # now that we have the org environments, we iterate between them to fetch the app data
        environments.each do |environment|
          environment_id = environment['id']
          environment_name = environment['name']
          @logger.info("fetching app data for organization #{organization_name} and environment #{environment_name}")
          # fetch the applications for the current environment and generate the logstash event
          applications = api.apps(organization_id, environment_id)
          break if applications.empty?
          push_data(applications, environment_name, organization_name, queue)
        end

        break if stop?
      end

      Stud.stoppable_sleep(@interval) { stop? }
    end
  end

  def push_data applications, environment, organization, queue
    for application in applications do
      data_event = LogStash::Event.new(
        'organization' => organization,
        'environment' => environment,
        'application' => application['domain'],
        'status' => application['status'],
        'workers' => application['workers'],
        'muleVersion' => application['muleVersion']['version']
      )
      decorate(data_event)
      queue << data_event
    end
  end

  def stop
    @logger.info("Stopping CloudHub App plugin")
  end

end
