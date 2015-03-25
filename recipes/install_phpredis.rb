#
# Cookbook Name:: module
# Recipe:: install_phpredis
#
# Copyright 2015, higashi.ryohei@nifty.co.jp
#
# All rights reserved - Do Not Redistribute
#

::Chef::Recipe.send(:include, Phpenv::Helpers)
::Chef::Provider.send(:include, Phpenv::Helpers)
::Chef::Resource.send(:include, Phpenv::Helpers)

ruby_block "install_phpredis#set-env-phpenv" do
  block do
    ENV["PHPENV_ROOT"] = node["phpenv"]["root_path"]
    ENV["PATH"] = "#{ENV['PHPENV_ROOT']}/bin:#{ENV['PATH']}"
  end
  not_if { ENV["PATH"].include?(node["phpenv"]["root_path"]) }
end

git File.join(node["phpenv"]["phpredis"]["src_dir"], "phpredis") do
  repository "git://github.com/nicolasff/phpredis.git"
  reference  "master"
  action     :sync
  user       node["phpenv"]["user"]
  group      node["phpenv"]["group"]
end
bash "compile phpredis" do
  cwd   File.join(node["phpenv"]['phpredis']['src_dir'], "phpredis")
  user  node["phpenv"]["user"]
  group node["phpenv"]["group"]
  code <<-EOH
    eval "$(phpenv init -)"
    phpize
    ./configure
    make
    make install
  EOH
end
