This is [IronMQ](http://www.iron.io/products/mq) backend for [delayed_job](http://github.com/collectiveidea/delayed_job)

# Getting Started

## Get credentials

To start using delayed_job_ironmq, you need to sign up and get an oauth token.

1. Go to http://iron.io/ and sign up.
2. Get an Oauth Token at http://hud.iron.io/tokens

## Installation

Add the gems to your `Gemfile:`

```ruby
gem 'delayed_job'
gem 'delayed_job_ironmq'
```

And add an initializer (`config/initializers/delayed_job_config.rb`):

```ruby
Delayed::Worker.configure do |config|
  config.token = 'XXXXXXXXXXXXXXXX'
  config.project_id = 'XXXXXXXXXXXXXXXX'

  # optional params:
  config.available_priorities = [-1,0,1,2] # Default is [0]. Please note, each new priority will speed down a bit picking job from queue
  config.queue_name = 'default' # Specify an alternative queue name
  config.delay = 0  # Time to wait before message will be available on the queue
  config.timeout = 5.minutes # The time in seconds to wait after message is taken off the queue, before it is put back on. Delete before :timeout to ensure it does not go back on the queue.
  config.expires_in = 7.days # After this time, message will be automatically removed from the queue.
 end
end
```

## Usage

That's it. Use [delayed_job as normal](http://github.com/collectiveidea/delayed_job).

Example:

```ruby
class TestJob < Struct.new(:a, :b)
  def perform
    puts  a/b
  end
end
Delayed::Job.enqueue TestJob.new(10, 2)

```

# Documentation

You can find more documentation here:

* http://iron.io
* http://dev.iron.io