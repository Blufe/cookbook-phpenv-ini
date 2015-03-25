#
# Cookbook Name:: module
# Recipe:: configure_phpredis
#
# Copyright 2015, higashi.ryohei@nifty.co.jp
#
# All rights reserved - Do Not Redistribute
#

::Chef::Recipe.send(:include, Phpenv::Helpers)
::Chef::Provider.send(:include, Phpenv::Helpers)
::Chef::Resource.send(:include, Phpenv::Helpers)

ruby_block "configure_phpredis#set-env-phpenv" do
  block do
    ENV["PHPENV_ROOT"] = node["phpenv"]["root_path"]
    ENV["PATH"] = "#{ENV['PHPENV_ROOT']}/bin:#{ENV['PATH']}"
  end
  not_if { ENV["PATH"].include?(node["phpenv"]["root_path"]) }
end

t = template "/etc/conf.d/phpredis.ini" do
  source "phpredis.ini.erb"
  mode   0644
  owner  node["phpenv"]["user"]
  group  node["phpenv"]["group"]
  action :nothing
  notifies :reload, "service[apache2]", :delayed
  only_if do current_global_version end
end

ruby_block "phpredis#check-set-current_global_version" do
  block do
    if current_global_version then
      conf_file = File.join(node["phpenv"]["root_path"], "versions", current_global_version, "etc", "conf.d", "phpredis.ini")
      t.path(conf_file)
      t.run_action("create")
    else
      Chef::Log.warn(
        "phpenv: global php version is not set, use phpenv_global to set it (action will be skipped)"
      )
    end
  end
end

