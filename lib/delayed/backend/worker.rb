require_relative 'iron_mq_config'

module Delayed
  class Worker
    class << self
      attr_accessor :config, :ironmq,
                    :queue_name, :delay, :timeout, :expires_in, :available_priorities

      def configure
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

          priorities      = config.available_priorities || [0]
          if priorities.include?(0) && priorities.all?{|p|p.is_a?(Integer)}
            self.available_priorities = priorities.sort
          else
            raise ArgumentError, "available_priorities option has wrong format. Please provide array of Integer values, includes zero. Default is [0]."
          end
        else
          raise ArgumentError, "Required option missing. Please provide both 'token' and 'project_id'"
        end
      end

      def config
        @config ||= IronMqConfig.new
      end

    end
  end
end