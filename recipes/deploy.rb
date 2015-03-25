#
# Cookbook Name:: module
# Recipe:: deploy_control_panel
#
# Copyright 2015, higashi.ryohei@nifty.co.jp
#
# All rights reserved - Do Not Redistribute
#

require "find"
Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)

application_info = node["control_panel"]
application_name = application_info["name"]
application      = node["deploy"][application_name]
if application.nil? then
  Chef::Log.info("skip deploy #{application_name}.")
  return 0
else
  Chef::Log.info("application : #{application}")
end

opsworks_deploy_dir do
  user  application[:user]
  group application[:group]
  path  application[:deploy_to]
end

opsworks_deploy do
  app         application_name
  deploy_data application
end

ruby_block "deploy#set-env-phpenv" do
  block do
    unless ENV["PATH"].include?(node["phpenv"]["root_path"]) then
      ENV["PHPENV_ROOT"] = node["phpenv"]["root_path"]
      ENV["PATH"] = "#{ENV['PHPENV_ROOT']}/bin:#{ENV['PATH']}"
    end
    ENV["PATH"] = %{#{ENV["PATH"]}:#{shell_out(%{eval "$(phpenv init -)" && echo $PATH}).stdout}}
    Chef::Log.debug(ENV["PATH"])
  end
end

ruby_block "deploy#set-env-nodebrew" do
  block do
    unless ENV["PATH"].include?(node["nodebrew"]["root"]) then
      ENV["NODEBREW_ROOT"] = node["nodebrew"]["root"]
      ENV["PATH"] = "#{ENV['NODEBREW_ROOT']}/current/bin:#{ENV['PATH']}"
    end
  end
end

conf            = application_info["config"]
api_dir         = File.join(application[:current_path], "api")
web_dir         = File.join(application[:current_path], "web")
apache_conf_dir = File.join(node["apache"]["dir"], "sites-available")

composer_package api_dir do
  user   application[:user]
  group  application[:group]
  dev    false
  action :install
end

%w{
  compiled
  cache
}.each do |file|
  directory File.join(web_dir, file) do
    owner     node["apache"]["user"]
    group     node["apache"]["group"]
    recursive true
    mode      0755
    action    :create
  end
end

composer_package web_dir do
  user   application[:user]
  group  application[:group]
  dev    false
  action :install
end

nodebrew_npm "npm install #{web_dir}" do
  node_version node["nodebrew"]["use"]
  path         web_dir
  package_json true
  user         application[:user]
  group        application[:group]
  environment  "HOME" => File.join("/home", application[:user])
end

bash "bower install" do
  cwd   web_dir
  user  application[:user]
  group application[:group]
  code  "bower install"
  environment "HOME" => File.join("/home", application[:user])
end

bash "gulp" do
  cwd   web_dir
  user  application[:user]
  group application[:group]
  code  "gulp"
  environment "HOME" => File.join("/home", application[:user])
end

include_recipe "module::configure"
