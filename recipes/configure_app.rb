#
# Cookbook Name:: module
# Recipe:: configure_control_panel_app
#
# Copyright 2015, higashi.ryohei@nifty.co.jp
#
# All rights reserved - Do Not Redistribute
#

require "find"
Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)

application_info = node["control_panel"]
conf             = application_info["config"]
api_dir          = File.join(application_info["docroot"], "api")
web_dir          = File.join(application_info["docroot"], "web")

api_conf = conf["api"]
if api_conf.class() != String then
  api_conf = "custom"
  template File.join(api_dir, "config", "custom.php") do
    source "app.config.php.erb"
    mode   0644
    owner  application_info["user"]
    group  application_info["group"]
    action :create
    variables({
       :config       => conf["api"]["define"],
       :require_once => conf["api"]["require_once"]
    })
  end
end

link File.join(api_dir, "config", "config.php") do
  to     "#{api_conf}.php"
  owner  application_info["user"]
  group  application_info["group"]
  action :create
  only_if { File.file?(File.join(api_dir, "config", "#{api_conf}.php")) }
end

web_conf = conf["web"]
if web_conf.class() != String then
  web_conf = "custom"
  template File.join(web_dir, "config", "custom.php") do
    source "app.config.php.erb"
    mode   0644
    owner  application_info["user"]
    group  application_info["group"]
    action :create
    variables({
       :config       => conf["web"]["define"],
       :require_once => conf["web"]["require_once"]
    })
  end
end

link File.join(web_dir, "config", "config.php") do
  to     "#{web_conf}.php"
  owner  application_info["user"]
  group  application_info["group"]
  action :create
  only_if { File.file?(File.join(web_dir, "config", "#{web_conf}.php")) }
end
