#
# Cookbook Name:: devstack
# Recipe:: default
#
# Copyright 2012, Rackspace US, Inc.
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
#

include_recipe 'git'
include_recipe 'sudo'

user node['devstack']['user'] do
  comment  "Devstack User"
  shell    "/bin/bash"
end

sudo 'devstack' do
  user      node['devstack']['user']   # or a username
  commands  ['ALL']
  nopasswd  true
end

directory "#{node['devstack']['dest']}" do
  owner  node['devstack']['user']
  group node['devstack']['user']
  mode 00755
  action :create
  recursive true
end

git "#{node['devstack']['dest']}/devstack" do
  user node['devstack']['user']
  group node['devstack']['user']  
  repository node['devstack']['git_repo'] 
  reference  node['devstack']['git_branch']
end

template "localrc" do
   path  "#{node['devstack']['dest']}/devstack/localrc"
   owner node['devstack']['user']
   group node['devstack']['user']
   mode  00644
end

directory "/home/#{node['devstack']['user']}/.pip" do
  owner node['devstack']['user']
  group node['devstack']['user']
  mode 00644
  action :create
  recursive true
end

template "pip.conf" do
   path  "/home/#{node['devstack']['user']}/.pip/pip.conf"
   owner node['devstack']['user']
   group node['devstack']['user']
   mode  00644
end

if node['devstack']['enable_docker']
  execute "./tools/docker/install_docker.sh" do
    user    node['devstack']['user']
    command "sudo ./stack.sh >> #{node['devstack']['dest']}/devstack/devstack.log"
    cwd     "#{node['devstack']['dest']}/devstack"
  end

  ['socat', 'curl'].each do |supporting_package| 
    package supporting_package do
      action :install
    end
  end
end

execute "stack.sh" do
  user    node['devstack']['user']
  command "./stack.sh" # >> #{node['devstack']['dest']}/devstack/devstack.log"
  cwd     "#{node['devstack']['dest']}/devstack"
end
