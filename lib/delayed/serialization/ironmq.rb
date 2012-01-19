# encoding: utf-8

module DelayedJobIronmq
  class Document
    extend ActiveSupport::Concern
    #def initialize(message)
    #  @id = message.id
    #  @attributes = JSON.load(message.body)
    #end

  end
end

if YAML.parser.class.name =~ /syck/i
  DelayedJobIronmq::Document.class_eval do
    yaml_as "tag:ruby.yaml.org,2002:DelayedJobIronmq"

    def self.yaml_new(klass, tag, val)
      begin
        klass.find(val['attributes']['_id'])
      rescue
        raise Delayed::DeserializationError
      end
    end

    def to_yaml_properties
      ['@attributes']
    end
  end
else
  DelayedJobIronmq::Document.class_eval do
    def encode_with(coder)
      coder["attributes"] = @attributes
      coder.tag = ['!ruby/DelayedJobIronmq', self.class.name].join(':')
    end
  end
end