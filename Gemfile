source 'https://rubygems.org'

plugin 'bundler-inject', '~> 1.1'
require File.join(Bundler::Plugin.index.load_paths("bundler-inject")[0], "bundler-inject") rescue nil

gem "activesupport", "~> 5.2.2"
gem "cloudwatchlogger", "~> 0.2"
gem "concurrent-ruby"
gem "manageiq-loggers", "~> 0.4.0", ">= 0.4.2"
gem 'manageiq-messaging'
gem "more_core_extensions"
gem "optimist"
gem "prometheus_exporter", "~> 0.4.5"
gem "rake"
gem "rest-client", "~>2.0"
gem "sources-api-client",                       :git => "https://github.com/ManageIQ/sources-api-client-ruby", :branch => "master"
gem "topological_inventory-ingress_api-client", :git => "https://github.com/ManageIQ/topological_inventory-ingress_api-client-ruby", :branch => "master"
gem "topological_inventory-providers-common",   :git => "https://github.com/ManageIQ/topological_inventory-providers-common", :branch => "master"

group :test, :development do
  gem "rspec"
  gem "simplecov"
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
