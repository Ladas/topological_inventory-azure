#
# Uses the AWS Config or CloudWatch service to monitor for events.
#
# AWS Config or CloudWatch events are collected in an SNS Topic.  Each appliance uses a unique
# SQS queue subscribed to the AWS Config topic.  If the appliance-specific queue
# doesn't exist, this event monitor will create the queue and subscribe the
# queue to the AWS Config topic.

require "topological_inventory/azure/connection"
require 'aws-sdk'
require "concurrent"
require "manageiq-messaging"

module TopologicalInventory::Azure
  class EventCatcher
    class ProviderUnreachable < StandardError
    end

    attr_reader :source, :sns_topic_name

    def initialize(source, region, access_key_id, secret_access_key, sns_topic, queue_host, queue_port, poll_time: 20)
      self.log               = Logger.new(STDOUT)
      self.secret_access_key = secret_access_key
      self.access_key_id     = access_key_id
      self.region            = region
      self.sns_topic_name    = sns_topic
      self.poll_time         = poll_time
      self.queue_host        = queue_host
      self.queue_port        = queue_port
      self.source            = source
    end

    def sqs_connection(scope = {})
      @sqs_connection ||= Connection.sqs(connection_attributes.merge(scope))
    end

    def sns_connection(scope = {})
      @sns_connection ||= Connection.sns(connection_attributes.merge(scope))
    end

    def monitor_events!
      poll do |event|
        publish_message(
          :source => source,
          :region => region,
          :data   => event.to_hash
        )
      end
    end

    private

    attr_accessor :log, :secret_access_key, :access_key_id, :region, :poll_time, :queue, :queue_host, :queue_port

    attr_writer :source, :sns_topic_name

    def publish_message(message)
      messaging_client.publish_message(
        :service => "platform.topological-inventory.event-stream",
        :message => "event",
        :payload => message,
      )
    end

    def messaging_client
      ManageIQ::Messaging::Client.open(messaging_opts)
    end

    def messaging_opts
      {
        :protocol => :Kafka,
        :host     => queue_host,
        :port     => queue_port,
        :encoding => "json",
      }
    end

    def connection_attributes
      {:access_key_id => access_key_id, :secret_access_key => secret_access_key, :region => region}
    end

    #
    # Collect events off the appliance-specific queue and return the events as a
    # batch to the caller.
    #
    # :yield: array of Azure events as hashes
    #
    def poll
      queue_poller = Aws::SQS::QueuePoller.new(
        find_or_create_queue,
        :client            => sqs_connection.client,
        :wait_time_seconds => 20,
        # :max_number_of_messages => 10
      )
      begin
        queue_poller.poll do |sqs_message|
          yield sqs_message if sqs_message
        end
      rescue Aws::SQS::Errors::ServiceError => exception
        raise ProviderUnreachable, exception.message
      end
    end

    # @return [String] is a queue_url
    def find_or_create_queue
      queue_url = sqs_get_queue_url(queue_name)
      subscribe_topic_to_queue(sns_topic, queue_url) unless queue_subscribed_to_topic?(queue_url, sns_topic)
      add_policy_to_queue(queue_url, sns_topic.arn) unless queue_has_policy?(queue_url, sns_topic.arn)
      queue_url
    rescue Aws::SQS::Errors::NonExistentQueue
      # $aws_log.info("#{log_header} Azure SQS Queue #{queue_name} does not exist; creating queue")
      queue_url = sqs_create_queue(queue_name)
      subscribe_topic_to_queue(sns_topic, queue_url)
      add_policy_to_queue(queue_url, sns_topic.arn)
      # $aws_log.info("#{log_header} Created Azure SQS Queue #{queue_name} and subscribed to AWSConfig_topic")
      queue_url
    rescue Aws::SQS::Errors::ServiceError => exception
      raise ProviderUnreachable, exception.message
    end

    def queue_has_policy?(queue_url, topic_arn)
      policy_attribute = 'Policy'
      policy           = sqs_connection.client.get_queue_attributes(
        :queue_url       => queue_url,
        :attribute_names => [policy_attribute]
      ).attributes[policy_attribute]

      policy == queue_policy(queue_url_to_arn(queue_url), topic_arn)
    end

    def queue_subscribed_to_topic?(queue_url, topic)
      queue_arn = queue_url_to_arn(queue_url)
      topic.subscriptions.any? { |subscription| subscription.attributes['Endpoint'] == queue_arn }
    end

    def sqs_create_queue(queue_name)
      sqs_connection.client.create_queue(:queue_name => queue_name).queue_url
    end

    def sqs_get_queue_url(queue_name)
      # $aws_log.debug("#{log_header} Looking for Azure SQS Queue #{queue_name} ...")
      sqs_connection.client.get_queue_url(:queue_name => queue_name).queue_url
    end

    # @return [Aws::SNS::Topic] the found topic
    # @raise [ProviderUnreachable] in case the topic is not found
    def sns_topic
      @sns_topic ||= get_topic(sns_connection) || create_topic(sns_connection)
    end

    def get_topic(sns)
      sns.topics.detect { |t| t.arn.split(/:/)[-1] == sns_topic_name }
    end

    def create_topic(sns)
      topic = sns.create_topic(:name => sns_topic_name)
      # $aws_log.info("Created SNS topic #{sns_topic_name}")
      topic
    rescue Aws::SNS::Errors::ServiceError => err
      raise ProviderUnreachable, "Cannot create SNS topic #{sns_topic_name}, #{err.class.name}, Message=#{err.message}"
    end

    # @param [Aws::SNS::Topic] topic
    def subscribe_topic_to_queue(topic, queue_url)
      queue_arn = queue_url_to_arn(queue_url)
      # $aws_log.info("#{log_header} Subscribing Queue #{queue_url} to #{topic.arn}")
      subscription = topic.subscribe(:protocol => 'sqs', :endpoint => queue_arn)
      raise ProviderUnreachable, "Can't subscribe to #{queue_arn}" if subscription.arn.nil? || subscription.arn.empty?
    end

    def add_policy_to_queue(queue_url, topic_arn)
      queue_arn = queue_url_to_arn(queue_url)
      policy    = queue_policy(queue_arn, topic_arn)

      sqs_connection.client.set_queue_attributes(
        :queue_url  => queue_url,
        :attributes => {'Policy' => policy}
      )
    end

    def queue_url_to_arn(queue_url)
      @queue_url_to_arn            ||= {}
      @queue_url_to_arn[queue_url] ||= begin
        arn_attribute = "QueueArn"
        sqs_connection.client.get_queue_attributes(
          :queue_url       => queue_url,
          :attribute_names => [arn_attribute]
        ).attributes[arn_attribute]
      end
    end

    def log_header
      @log_header ||= "(#{self.class.name}#)"
    end

    def queue_name
      # Generating the same queue name for source, so we can scale the event catcher
      @queue_name ||= "topological-inventory-awsconfig-queue_#{self.source}"
    end

    def queue_policy(queue_arn, topic_arn)
      <<EOT
{
  "Version": "2012-10-17",
  "Id": "#{queue_arn}/SQSDefaultPolicy",
  "Statement": [
    {
      "Sid": "#{Digest::MD5.hexdigest(queue_arn)}",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SQS:SendMessage",
      "Resource": "#{queue_arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "#{topic_arn}"
        }
      }
    }
  ]
}
EOT
    end
  end
end
