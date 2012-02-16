

module Delayed
  module Backend
    module Ironmq
      class Job
        include ::DelayedJobIronmq::Document
        include Delayed::Backend::Base
        extend  Delayed::Backend::Ironmq::Actions

        field :priority,    :type => Integer, :default => 0
        field :attempts,    :type => Integer, :default => 0
        field :handler,     :type => String
        field :run_at,      :type => Time
        field :locked_at,   :type => Time
        field :locked_by,   :type => String
        field :failed_at,   :type => Time
        field :last_error,  :type => String
        field :queue,       :type => String

        def initialize(data = {})
          puts "[init] Delayed::Backend::Ironmq"
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

        def save
          puts "[SAVE] #{@attributes.inspect}"

          if @attributes[:handler].blank?
            raise "Handler missing!"
          end
          payload = JSON.dump(@attributes)

          ironmq.messages.delete(@id, queue_name: queue_name) if @id.present?
          ironmq.messages.post(payload,
            timeout:    @timeout,
            queue_name: queue_name,
            delay:      @delay,
            expires_in: @expires_in)
          true
        end

        def save!
          save
        end

        def destroy
          if @id
            puts "job destroyed! #{@id.inspect}"
            ironmq.messages.delete(@id, queue_name: queue_name) if @id.present?
          end
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
        def unlock(*args)
          true
        end

        def reload(*args)
          # reset
          super
        end

        private

        def queue_name
          "#{@queue_name}_#{@attributes[:priority] || 0}"
        end

        def ironmq
          ::Delayed::Worker.ironmq
        end
      end
    end
  end
end