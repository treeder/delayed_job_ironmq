# encoding: utf-8
require 'iron_mq'
require 'delayed_job'
require 'delayed/serialization/ironmq'
require 'delayed/backend/ironmq'

Delayed::Worker.backend = :ironmq
