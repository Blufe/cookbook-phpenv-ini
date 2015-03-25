#
# Cookbook Name:: module
# Recipe:: configure_route
#
# Copyright 2015, higashi.ryohei@nifty.co.jp
#
# All rights reserved - Do Not Redistribute
#

application_info = node["control_panel"]
application_info["route"]["target"].split(/\s*,\s*/).each do |target|
  route "#{target}" do
    target         target
    gateway        application_info["route"]["gateway"]
    retries        application_info["route"]["retries"]
    retry_delay    application_info["route"]["retry_delay"]
    ignore_failure application_info["route"]["ignore_failure"]
    action :add
  end
end
