# encoding: utf-8

require_relative 'cloudhub_client'
require_relative 'sincedb'

require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "fileutils"
require "socket"

# This input plugin reads log messages from the Anypoint REST API.
# You don't need to configure your environments/applications, the
# plugin will fetch all.
class LogStash::Inputs::Cloudhub < LogStash::Inputs::Base
  config_name "cloudhub"

  # Anypoint user name
  config :username, :validate => :string
  # Anypoint password
  config :password, :validate => :string
  # Anypoint organization id
  config :organization_id, :validate => :string
  # CloudHub organization environment name, default is 'Development'
  config :environment_name, :validate => :string, :default => 'Development'
  # Interval (in seconds) between two log fetches.
  # (End of previous fetch to start of next fetch)
  # Default value: 300
  config :interval, :validate => :number, :default => 300
  # How many events should be fetched in one REST call?
  # Default: 100
  config :events_per_call, :validate => :number, :default => 100
  # Folder for sincedb files, default is /usr/share/logstash/data
  config :sincedb_folder, :validate => :string, :default => "/usr/share/logstash/data"
  # File name prefix for sincedb files, default is 'sincedb-'
  config :sincedb_prefix, :validate => :string, :default => 'sincedb-'

  default :codec, "plain"

  public
  def register
    @host = Socket.gethostname
    @sincedb = SinceDB.new @sincedb_folder, @sincedb_prefix
  end

  def run(queue)
    api = CloudhubClient.new @logger, @username, @password, @organization_id, @events_per_call

    while !stop?
      # get the token once per main loop (more efficient than fetching it for each API call)
      token = api.token()
      # fetch all organization data
      organization = api.organization(@organization_id, token)
      organization_name = organization['name']

      #get all organization environments, and iterate to find the desired one
      environment = nil
      environments = organization['environments']
      environments.each do |env|
        next if env['name'] != @environment_name
        environment = env
      end

      # get all applications under this org and environment
      applications = api.apps(@organization_id, environment['id'], token)

      # fetch logs from all apps
      applications.each do |application|
        # fetches the current deployment to only fetch currently application logs
        application_domain = application['domain']
        current_deployment = api.current_deployment(application_domain, @organization_id, environment['id'], token)
        begin
          @logger.info("Fetching logs for " + application_domain)
          first_start_time = @sincedb.read(application_domain)
          start_time = first_start_time
          while !stop?
            logs = api.logs(start_time, environment['id'], application_domain, current_deployment['deploymentId'], token)
            break if logs.empty?
            start_time = logs[-1]['event']['timestamp'] + 1
            push_logs(logs, @environment_name, application_domain, organization_name, queue)
          end
        rescue => exception
          puts exception.backtrace
        end
        if (start_time > first_start_time)
          @sincedb.write(application_domain, start_time)
        end
        break if stop?
      end
      Stud.stoppable_sleep(@interval) { stop? }
    end
  end

  def push_logs logs, environment, domain, organization, queue
    for log in logs do
      event = log['event']
      log_event = LogStash::Event.new(
        'environment' => environment,
        'application' => domain,
        'organization' => organization,
        'line' => log['line'],
        'loggerName' => event['loggerName'],
        'threadName' => event['threadName'],
        'priority' => event['priority'],
        'log_timestamp' => event['timestamp'],
        'message' => event['message']
      )
      decorate(log_event)
      queue << log_event
    end
  end

  def stop
    @logger.info("Stopping CloudHub plugin")
  end

end
