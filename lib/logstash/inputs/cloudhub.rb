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
  # Environment name for the logstash events
  config :environment_name, :validate => :string
  # Anypoint Organization environment id
  config :environment_id, :validate => :string
  # Interval (in seconds) between two log fetches.
  # (End of previous fetch to start of next fetch)
  # Default value: 300
  config :interval, :validate => :number, :default => 300
  # How many events should be fetched in one REST call?
  # Default: 100
  config :events_per_call, :validate => :number, :default => 100
  # Folder for sincedb files, default is <logstash>/data/plugins/cloudhub
  config :sincedb_folder, :validate => :string, :default => nil
  # File name prefix for sincedb files, default is 'sincedb-'
  config :sincedb_prefix, :validate => :string, :default => 'sincedb-'

  default :codec, "plain"

  public
  def register
    @host = Socket.gethostname
    @sincedb = SinceDB.new @sincedb_folder, @sincedb_prefix
  end

  def run(queue)
    api = CloudhubClient.new @logger, @username, @password, @organization_id, @environment_id, @events_per_call

    while !stop?
      # get the token once per main loop (more efficient than fetching it for each API call)
      token = api.token()
      # get all applications under this org and environment
      applications = api.apps(@organization_id, @environment_id, token)

      # iterates between apps, fetching logs
      applications.each do |application|
        application_name = application['domain']
        begin
          @logger.info("Fetching logs for " + application_name)
          first_start_time = @sincedb.read(application_name)
          start_time = first_start_time
          while !stop?
            logs = api.logs(start_time, @environment_id, application_name, token)
            break if logs.empty?
            start_time = logs[-1]['event']['timestamp'] + 1
            push_logs(logs, @environment_name, application_name, queue)
          end
        rescue => exception
          puts exception.backtrace
        end
        if (start_time > first_start_time)
          @sincedb.write(application_name, start_time)
        end
        break if stop?
      end
      Stud.stoppable_sleep(@interval) { stop? }
    end
  end

  def push_logs logs, environment, domain, queue
    for log in logs do
      event = log['event']
      log_event = LogStash::Event.new(
        'host' => @host,
        'environment' => environment,
        'application' => domain,

        'deploymentId' => log['deploymentId'],
        'instanceId' => log['instanceId'],
        'recordId' => log['recordId'],

        'line' => log['line'],
        'loggerName' => event['loggerName'],
        'threadName' => event['threadName'],
        'priority' => event['priority'],
        'timestamp' => event['timestamp'],
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
