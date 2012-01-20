# encoding: utf-8
module Delayed
  class Worker
    cattr_accessor :ironmq
  end
end

module Delayed
  module Backend
    module Ironmq
      class Job
        include ::DelayedJobIronmq::Document
        include Delayed::Backend::Base

        def initialize(data = {}, *args)
          puts "Delayed::Backend::Ironmq - init : #{data.inspect} | #{args.inspect}"
          @id = nil
          if data.is_a?(IronMQ::Message)
            @id = data.id
            data = JSON.load(data.body)
          end
          payload_obj = data.delete(:payload_object) || data.delete("handler")
          @attributes = data
          self.payload_object = payload_obj
          #{:priority=>0, :payload_object=>#<struct TestJob text=nil, emails=nil>}
          puts "\n@attributes: #{@attributes.inspect})\n"


        end

        def payload_object
          puts "\npayload_object(): #{@attributes.inspect} | #{self.handler.inspect}\n"
          @payload_object ||= YAML.load(self.handler)
        rescue TypeError, LoadError, NameError, ArgumentError => e
          raise DeserializationError,
            "Job failed to load: #{e.message}. Handler: #{handler.inspect}"
        end

        def payload_object=(object)
          puts "\npayload_object=(#{object.inspect})\n"
          @payload_object = object
          self.handler = object.to_yaml
        end

        def self.field(name, options = {})
          type    = options[:type]    || String
          default = options[:default] || nil
          define_method name do |*args|
            @attributes ||= {}
            @attributes[name.to_s] || default
          end
          define_method "#{name}=" do |value|
            @attributes ||= {}
            @attributes[name.to_s] = value
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
          "dj_ironmq10"
        end

        def self.find_available(worker_name, limit = 5, max_run_time = Worker.max_run_time)
          limit = 5
          #queue_name = "dj_ironmq6"
          puts "Reserve #1.1 | queue_name: #{queue_name}"
          messages = ironmq.messages.get(queue_name: queue_name, n: limit)
          puts "Reserve #1.2 | messages: #{messages.inspect}"
          return [] if messages.blank?
          messages.map do |message|
            Delayed::Backend::Ironmq::Job.new(message)
          end
        end

        def save
          puts "\nsave()\n"
          #self.class.queue_name = "dj_ironmq6"
          puts "\n  id: #{@id.inspect}\n"
          puts "\n  attributes: #{@attributes.inspect}\n"
          if @attributes['handler'].blank?
             return false
          end
          payload = JSON.dump(@attributes)
          timeout = 60

          ironmq.messages.delete(@id) if @id.present?
          ironmq.messages.post(payload, timeout: timeout, queue_name: self.class.queue_name)
          true
        end

        def save!
          save
        end

        def update_attributes(attributes)
          puts "\nself.class.queue_name#{self.class.queue_name.inspect})\n"
          puts "\nupdate_attributes(#{attributes.inspect})\n"
          @attributes.merge attributes
          puts "\n@attributes: #{@attributes.inspect})\n"
          puts "\npayload_object: #{payload_object.inspect})\n"
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

        def delete_all
          #TODO delete_all
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