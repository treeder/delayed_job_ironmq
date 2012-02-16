class IronMqConfig
    attr_accessor :token, :project_id,
                  :queue_name, :delay, :timeout,
                  :expires_in, :available_priorities
end