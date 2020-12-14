source 'https://rubygems.org'

plugin 'bundler-inject', '~> 1.1'
require File.join(Bundler::Plugin.index.load_paths("bundler-inject")[0], "bundler-inject") rescue nil

gem "activesupport", '~> 5.2.4.3'
gem "cloudwatchlogger", "~> 0.2.1"
gem "concurrent-ruby"
gem "manageiq-loggers", "~> 0.5.0"
gem "manageiq-messaging", "~> 1.0.0"
gem "more_core_extensions"
gem "optimist"
gem "prometheus_exporter", "~> 0.4.5"
gem "rake", ">= 12.3.3"
gem "rest-client", "~>2.0"
gem "sources-api-client", "~> 3.0"
gem "topological_inventory-ingress_api-client", "~> 1.0.2"
gem "topological_inventory-providers-common", "~> 2.1.4"

group :test, :development do
  gem "rspec"
  gem "rubocop",             "~> 1.0.0", :require => false
  gem "rubocop-performance", "~> 1.8",   :require => false
  gem "rubocop-rails",       "~> 2.8",   :require => false
  gem "simplecov",           "~>0.17.1"
  gem "webmock"
end

gem "azure_mgmt_compute", "~>0.18.7"
gem "azure_mgmt_monitor", "~>0.17.4"
gem "azure_mgmt_network", "~>0.19.0"
gem "azure_mgmt_resources", "~>0.17.6"
gem "azure_mgmt_storage", "~>0.17.10"
gem "azure_mgmt_subscriptions", "~>0.17.3"
gem "ms_rest_azure", "~>0.11.1"

gem 'azure-storage-blob', "~>1.1.0"
