#
# Cookbook Name:: module
# Recipe:: configure_log
#
# Copyright 2015, higashi.ryohei@nifty.co.jp
#
# All rights reserved - Do Not Redistribute
#

application_info = node["control_panel"]
application_name = application_info["name"]

directory application_info["log_dir"] do
  owner     node["apache"]["user"]
  group     node["apache"]["group"]
  recursive true
  mode      0755
  action    :create
  not_if { File.exists?(application_info["log_dir"]) }
end

logrotate_info = application_info["logrotate"]
logrotate_app application_name do
  cookbook  "logrotate"
  path      File.join(application_info["log_dir"],"*.log")
  frequency logrotate_info["schedule"]
  rotate    logrotate_info["rotate"]
  create    "#{logrotate_info["mode"]} #{logrotate_info["owner"]} #{logrotate_info["group"]}"
  options   logrotate_info["options"]
end
