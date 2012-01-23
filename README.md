


`Gemfile`:

```ruby
# ...
gem 'delayed_job'
gem 'delayed_job_ironmq'
# ...
```

`config/initializers/delayed_job_config.rb`:

```ruby
Delayed::Worker.configure do |config|
  config.token = 'XXXXXXXXXXXXXXXX'
  config.project_id = 'XXXXXXXXXXXXXXXX'
  config.queue_name = 'default' # optional
end
```