# encoding: utf-8

module DelayedJobIronmq
  module Document
    #extend ActiveSupport::Concern
    #def initialize(message)
    #  @id = message.id
    #  @attributes = JSON.load(message.body)
    #end
    yaml_as "tag:ruby.yaml.org,2002:MongoMapper"

    def self.yaml_new(klass, tag, val)
      puts "yaml_new: #{klass.inspect},#{tag.inspect}, #{val.inspect}"
      klass.find!(val['_id'])
    rescue MongoMapper::DocumentNotFound
      raise Delayed::DeserializationError
    end

    def to_yaml_properties
      ['@attributes']
    end

  end
end