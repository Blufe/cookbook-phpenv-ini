#
# Cookbook Name:: module
# Recipe:: install_apc
#
# Copyright 2015, higashi.ryohei@nifty.co.jp
#
# All rights reserved - Do Not Redistribute
#

::Chef::Recipe.send(:include, Phpenv::Helpers)
::Chef::Provider.send(:include, Phpenv::Helpers)
::Chef::Resource.send(:include, Phpenv::Helpers)

ruby_block "install_apc#set-env-phpenv" do
  block do
    ENV["PHPENV_ROOT"] = node["phpenv"]["root_path"]
    ENV["PATH"] = "#{ENV['PHPENV_ROOT']}/bin:#{ENV['PATH']}"
  end
  not_if { ENV["PATH"].include?(node["phpenv"]["root_path"]) }
end

# http://pecl.php.net/get/APC-#{node["phpenv"]["apc"]["version"]}.tgz
cookbook_file "APC-#{node["phpenv"]["apc"]["version"]}" do
  source "APC-#{node["phpenv"]["apc"]["version"]}.tgz"
  path   File.join(node["phpenv"]["apc"]["src_dir"], "APC-#{node["phpenv"]["apc"]["version"]}.tgz")
  owner  node["phpenv"]["user"]
  group  node["phpenv"]["group"]
  action :create_if_missing
end
bash "compile apc" do
  cwd   File.join(node["phpenv"]['apc']['src_dir'])
  user  node["phpenv"]["user"]
  group node["phpenv"]["group"]
  code <<-EOH
    tar zxvf APC-#{node["phpenv"]["apc"]["version"]}.tgz
    cd APC-#{node["phpenv"]["apc"]["version"]}
    eval "$(phpenv init -)"
    phpize
    ./configure --enable-apc --with-apxs
    make
    make install
  EOH
end
