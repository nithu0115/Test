#
# Cookbook:: activemq
# Recipe:: default
#
# Copyright:: 2009-2016, Chef Software, Inc.
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

include_recipe 'java::default' if node['activemq']['install_java']

tmp = Chef::Config[:file_cache_path]
version = node['activemq']['version']
mirror = node['activemq']['mirror']
activemq_home = "#{node['activemq']['home']}/apache-artemis-#{version}"

directory node['activemq']['home'] do
  recursive true
end

unless File.exist?("#{activemq_home}/bin/artemis")
  remote_file "#{tmp}/apache-artemis-#{version}-bin.tar.gz" do
    source "#{mirror}/#{version}/apache-artemis-#{version}-bin.tar.gz"
    mode '0644'
  end

  package 'tar'

  execute "tar zxf #{tmp}/apache-artemis-#{version}-bin.tar.gz" do
    cwd node['activemq']['home']
  end
end

file "#{activemq_home}/bin/artemis" do
  owner 'root'
  group 'root'
  mode '0755'
end

#arch = node['kernel']['machine'] == 'x86_64' ? 'x86-64' : 'x86-32'

#link '/etc/init.d/activemq' do
#  to "#{activemq_home}/bin/linux-#{arch}/activemq"
#end

template "#{activemq_home}/etc/broker.xml" do
  source 'activemq.xml.erb'
  mode '0755'
  owner 'root'
  group 'root'
  notifies :restart, 'service[artemis]' if node['activemq']['enabled']
  only_if  { node['activemq']['use_default_config'] }
end

service 'artemis' do
  supports restart: true, status: true
  action [:enable, :start]
  only_if { node['activemq']['enabled'] }
end

# symlink so the default wrapper.conf can find the native wrapper library
#link "#{activemq_home}/bin/linux" do
 # to "#{activemq_home}/bin/linux-#{arch}"
#end

# symlink the wrapper's pidfile location into /var/run
link '/var/run/artemis.pid' do
  to "#{activemq_home}/data/artemis.pid"
  not_if 'test -f /var/run/artemis.pid'
end

#template "#{activemq_home}/bin/linux/wrapper.conf" do
 # source 'wrapper.conf.erb'
  #mode '0644'
  #only_if { node['activemq']['use_default_config'] }
  #notifies :restart, 'service[activemq]' if node['activemq']['enabled']
#end
