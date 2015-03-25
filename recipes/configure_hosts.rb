#
# Cookbook Name:: module
# Recipe:: configure_hosts
#
# Copyright 2015, higashi.ryohei@nifty.co.jp
#
# All rights reserved - Do Not Redistribute
#

node["control_panel"]["hosts"].each do |ip_address, host|
  hostsfile_entry ip_address do
    hostname host["hostname"]
    aliases  host["aliases"]
    unique   true
    action   :create
  end
end
