#
# Cookbook Name:: rails_chef
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
iptables_rule "ssh"
iptables_rule "http"

#rbenv_gem "passenger"

#template "#{node["nginx"]["dir"]}/conf.d/passenger.conf" do
#  source 'passenger.conf.erb'
#  owner 'root'
#  group 'root'
#  mode '0644'
#  notifies :reload, 'service[nginx]'
#end
