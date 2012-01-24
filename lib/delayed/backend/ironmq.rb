# encoding: utf-8
module Delayed
  class Worker

    class << self
      attr_accessor :config, :ironmq,
                    :queue_name, :delay, :timeout, :expires_in

      def configure()
        yield(config)
        if config && config.token && config.project_id
          Delayed::Worker.ironmq = IronMQ::Client.new(
              'token' => config.token,
              'project_id' => config.project_id
          )
          self.queue_name = config.queue_name || 'default'
          self.delay      = config.delay      || 0
          self.timeout    = config.timeout    || 5.minutes
          self.expires_in = config.expires_in || 7.days
        else
          # warn user
        end
      end

      def config
        @config ||= IronMqConfig.new
      end

    end
  end
end
class IronMqConfig
    attr_accessor :token, :project_id,
                  :queue_name, :delay, :timeout, :expires_in
end

module Delayed
  module Backend
    module Ironmq
      class Job
        include ::DelayedJobIronmq::Document
        include Delayed::Backend::Base

        def initialize(data = {})
          puts "[init] Delayed::Backend::Ironmq: #{data.inspect}"
          @id = nil
          if data.is_a?(IronMQ::Message)
            @id = data.id
            data = JSON.load(data.body)
          end

          data.symbolize_keys!
          payload_obj = data.delete(:payload_object) || data.delete(:handler)

          @queue_name = data[:queue_name] || Delayed::Worker.queue_name
          @delay      = data[:delay]      || Delayed::Worker.delay
          @timeout    = data[:timeout]    || Delayed::Worker.timeout
          @expires_in = data[:expires_in] || Delayed::Worker.expires_in

          @attributes = data
          self.payload_object = payload_obj
        end

        def payload_object
          @payload_object ||= YAML.load(self.handler)
        rescue TypeError, LoadError, NameError, ArgumentError => e
          raise DeserializationError,
            "Job failed to load: #{e.message}. Handler: #{handler.inspect}"
        end

        def payload_object=(object)
          if object.is_a? String
            @payload_object = YAML.load(object)
            self.handler = object
          else
            @payload_object = object
            self.handler = object.to_yaml
          end
        end

        def self.field(name, options = {})
          type    = options[:type]    || String
          default = options[:default] || nil
          define_method name do |*args|
            @attributes ||= {}
            @attributes[name.to_sym] || default
          end
          define_method "#{name}=" do |value|
            @attributes ||= {}
            @attributes[name.to_sym] = value
          end
        end

        field :priority,    :type => Integer, :default => 0
        field :attempts,    :type => Integer, :default => 0
        field :handler,     :type => String
        field :run_at,      :type => Time
        field :locked_at,   :type => Time
        field :locked_by,   :type => String
        field :failed_at,   :type => Time
        field :last_error,  :type => String
        field :queue,       :type => String


        def self.before_fork
        end

        def self.after_fork
        end

        def self.db_time_now
          Time.now.utc
        end

        def self.queue_name
          Delayed::Worker.queue_name
        end

        # not used now
        #def self.size
        #  Delayed::Worker.ironmq.queues.get(name: queue_name).size
        #end

        def self.find_available(worker_name, limit = 5, max_run_time = Worker.max_run_time)

          # [:queue] = Worker.queues if Worker.queues.any?

          messages = ironmq.messages.get(queue_name: queue_name, n: limit)
          puts "[Reserve] queue:  #{queue_name} | messages: #{messages.inspect}"
          messages.map do |message|
            Delayed::Backend::Ironmq::Job.new(message)
          end
        end

        def save
          if @attributes[:handler].blank?
            raise "Handler missing!"
          end
          payload = JSON.dump(@attributes)

          ironmq.messages.delete(@id, queue_name: @queue_name) if @id.present?
          ironmq.messages.post(payload,
                               timeout:    @timeout,
                               queue_name: @queue_name,
                               delay:      @delay,
                               expires_in: @expires_in)
          true
        end

        def save!
          save
        end

        def destroy
          puts "job destroyed! #{@id.inspect}"
          ironmq.messages.delete(@id, queue_name: @queue_name) if @id.present?
        end

        def fail!
          destroy
          # v2: move to separate queue
        end


        def update_attributes(attributes)
          attributes.symbolize_keys!
          @attributes.merge attributes
          save
        end

        # No need to check locks
        def lock_exclusively!(*args)
          true
        end

        # No need to check locks
        def self.clear_locks!(*args)
          true
        end
        # No need to check locks
        def unlock(*args)
          true
        end


        def reload(*args)
          # reset
          super
        end

        def self.delete_all
          puts "Queue: #{queue_name}"
          deleted = 0
          loop do
            msgs = ironmq.messages.get(n: 1000, queue_name: queue_name)
            break if msgs.blank?
            msgs.each do |msg|
              ironmq.messages.delete(msg.id, queue_name: queue_name)
              deleted += 1
            end
          end
          puts "Messages removed: #{deleted}"
        end

        private

        def ironmq
          ::Delayed::Worker.ironmq
        end

        def self.ironmq
          ::Delayed::Worker.ironmq
        end
      end
    end
  end
end