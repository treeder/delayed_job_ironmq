This is [IronMQ](http://www.iron.io/products/mq) backend for [delayed_job](http://github.com/collectiveidea/delayed_job)

# Getting Started

## Get credentials

Heroku users: Simply add the IronMQ add-on and you can skip the rest of this section. It will be setup
automatically when you add the IronMQ add-on.

To start using delayed_job_ironmq, you need to sign up for Iron.io and setup your credentials.

1. Go to http://iron.io/ and sign up.
2. Get an Oauth Token at http://hud.iron.io/tokens
3. Add an iron.json file or setup environment variables for authentication. See http://dev.iron.io/articles/configuration/ for details.

## Installation

Add the gems to your `Gemfile:`

```ruby
gem 'delayed_job'
gem 'delayed_job_ironmq'
```

Optionally: Add an initializer (`config/initializers/delayed_job.rb`):

```ruby
Delayed::Worker.configure do |config|
  # optional params:
  config.available_priorities = [-1,0,1,2] # Default is [0]. Please note, each new priority will speed down a bit picking job from queue
  config.queue_name = 'default' # Specify an alternative queue name
  config.delay = 0  # Time to wait before message will be available on the queue
  config.timeout = 5.minutes # The time in seconds to wait after message is taken off the queue, before it is put back on. Delete before :timeout to ensure it does not go back on the queue.
  config.expires_in = 7.days # After this time, message will be automatically removed from the queue.
end
```

## Usage

That's it. Use [delayed_job as normal](http://github.com/collectiveidea/delayed_job).

Example:

```ruby
class User
  def background_stuff
    puts "I run in the background"
  end
end
```

Then in one of your controllers:

```ruby
user = User.new
user.delay.background_stuff
```

## Start worker process

    rake jobs:work

That will start pulling jobs off the queue and processing them.

# Demo Rails Application

Here's a demo rails app you can clone and try it out: https://github.com/treeder/delayed_job_with_iron_mq

# Using with Heroku

To use with Heroku, just add the [IronMQ Add-on](https://addons.heroku.com/iron_mq) and
you're good to go.

# Documentation

You can find more documentation here:

* http://iron.io
* http://dev.iron.io
