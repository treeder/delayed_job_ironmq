module Delayed
  module Backend
    module Ironmq
      module Actions
        def field(name, options = {})
          #type   = options[:type]    || String
          default = options[:default] || nil
          define_method name do
            @attributes ||= {}
            @attributes[name.to_sym] || default
          end
          define_method "#{name}=" do |value|
            @attributes ||= {}
            @attributes[name.to_sym] = value
          end
        end

        def before_fork
        end

        def after_fork
        end

        def db_time_now
          Time.now.utc
        end

        #def self.queue_name
        #  Delayed::Worker.queue_name
        #end

        def find_available(worker_name, limit = 5, max_run_time = Worker.max_run_time)
          Delayed::Worker.available_priorities.each do |priority|
            messages = ironmq.messages.get(queue_name: queue_name(priority), n: 1)
            return [Delayed::Backend::Ironmq::Job.new(messages[0])] if messages[0]
          end
          []
        end

        def delete_all
          deleted = 0
          Delayed::Worker.available_priorities.each do |priority|
            loop do
              msgs = ironmq.messages.get(n: 1000, queue_name: queue_name(priority))
              break if msgs.blank?
              msgs.each do |msg|
                ironmq.messages.delete(msg.id, queue_name: queue_name(priority))
                deleted += 1
              end
            end
          end
          puts "Messages removed: #{deleted}"
        end

        # No need to check locks
        def clear_locks!(*args)
          true
        end

        private

        def ironmq
          ::Delayed::Worker.ironmq
        end

        def queue_name(priority)
          "#{Delayed::Worker.queue_name}_#{priority || 0}"
        end
      end
    end
  end
end