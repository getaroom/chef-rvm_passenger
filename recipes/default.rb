#
# Cookbook Name:: rvm_passenger
# Based on passenger_enterprise
# Recipe:: default
#
# Author:: Fletcher Nichol <fnichol@nichol.ca>
#
# Copyright:: 2010, 2011, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Chef::Recipe
  # mix in recipe helpers
  include Chef::RVMPassenger::RecipeHelpers
end

determine_gem_version_if_not_given
determine_rvm_ruby_if_not_given

rvm_ruby          = node['rvm_passenger']['rvm_ruby']
passenger_version = node['rvm_passenger']['version']

include_recipe "rvm::system"

Array(node['rvm_passenger']['common_pkgs']).each do |pkg|
  package pkg
end

rvm_environment rvm_ruby

rvm_gem "rack" do
  ruby_string rvm_ruby
  version node['rvm_passenger']['rack_version']
  only_if { node['rvm_passenger']['rack_version'] }
end

rvm_gem "passenger" do
  ruby_string rvm_ruby
  version     passenger_version
end

rvm_wrapper "passenger" do
  prefix node['rvm_passenger']['wrapper_prefix']
  binaries %w(passenger passenger-config passenger-memory-stats passenger-status)
  ruby_string rvm_ruby
end

node.default['rvm_passenger']['root_path'] = "/usr/local/rvm/gems/#{node['rvm_passenger']['rvm_ruby']}/gems/passenger-#{node['rvm_passenger']['version']}"

# calculate the ruby_wrapper attribute if it isn't set. This is evaluated in
# the execute phase because the RVM environment is queried and the Ruby must be
# installed.
ruby_block "Calculate node['rvm_passenger']['ruby_wrapper']" do
  block do
    Chef::RVMPassenger::CalculateAttribute.new(node).for_ruby_wrapper
  end
end
