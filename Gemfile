source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.6.0'
  gem "puppet-lint"
  gem "rspec-puppet"
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
end

group :development do
  gem "beaker"
  gem "beaker-rspec"
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
end
