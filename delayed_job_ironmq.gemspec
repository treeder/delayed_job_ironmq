Gem::Specification.new do |s|
  s.name              = 'delayed_job_ironmq'
  s.summary           = "IronMQ backend for delayed_job"
  s.version           = '0.0.1'
  s.authors           = ['Alexander Shapiotko']
  s.date              = Date.today.to_s
  s.email             = ['alexander@iron.io']
  s.extra_rdoc_files  = ["LICENSE", "README.md"]
  s.files             = Dir.glob("{lib,spec}/**/*") + %w[LICENSE README.md]
  s.homepage          = 'https://github.com/thousandsofthem/delayed_job_ironmq'
  s.rdoc_options      = ['--charset=UTF-8']
  s.require_paths     = ['lib']
  s.test_files        = Dir.glob('spec/**/*')

  s.add_runtime_dependency      'iron_mq',      '>= 1.4.0'
  s.add_runtime_dependency      'delayed_job',  '~> 3.0.0'
  s.add_development_dependency  'rspec',        '>= 2.0'
end