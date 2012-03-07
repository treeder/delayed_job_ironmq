# encoding: utf-8
require 'iron_mq'
require 'delayed_job'

require_relative 'delayed/serialization/ironmq'
require_relative 'delayed/backend/actions'
require_relative 'delayed/backend/iron_mq_config'
require_relative 'delayed/backend/worker'
require_relative 'delayed/backend/version'
require_relative 'delayed/backend/ironmq'

Delayed::Worker.backend = :ironmq
