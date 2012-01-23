# delayed_job IronMQ backend

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
  config.queue_name = 'default' # optional
end
```


That's it. Use [delayed_job as normal](http://github.com/collectiveidea/delayed_job).