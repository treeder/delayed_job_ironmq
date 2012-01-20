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

          if data.is_a?(IronMQ::Message)
            data = JSON.load(data.body)
          end
          payload_object = data.delete(:payload_object)
          @attributes = data
          #{:priority=>0, :payload_object=>#<struct TestJob text=nil, emails=nil>}


        end

        def self.field(name, options = {})
          type = options[:type] || String
          define_method name do |*args|
            @attributes ||= {}
            @attributes[name]
          end
          define_method "#{name}=" do |value|
            @attributes ||= {}
            @attributes[name] = value
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

        #def self.find_available(worker_name, , max_run_time = Worker.max_run_time)
        def self.reserve(worker, max_run_time = Worker.max_run_time)
          limit = 5

          queue_name = "dj_ironmq2"
          puts "Reserve #1.1"
          messages = ironmq.messages.get(queue_name: queue_name, n: limit)
          puts "Reserve #1.2"+messages.inspect
          return nil if messages.blank?
          messages.map do |message|
            Delayed::Backend::Ironmq::Job.new(message)
          end
        end

        def save
          queue_name = "dj_ironmq2"
          payload = JSON.dump(@attributes)
          timeout = 60
          ironmq.messages.post(payload, timeout: timeout, queue_name: queue_name)
          true
        end


        # No need to check locks
        def self.clear_locks!(worker_name = nil)
          return true
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