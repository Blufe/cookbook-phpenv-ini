#
# Cookbook Name:: module
# Recipe:: configure_php
#
# Copyright 2015, higashi.ryohei@nifty.co.jp
#
# All rights reserved - Do Not Redistribute
#

Array(node[:phpenv][:phps]).each do |php|
  if php.is_a?(Hash)
    version = php[:release]
    conf    = php[:conf]
    template "#{node[:phpenv][:root_path]}/versions/#{version}/etc/php.ini" do
      source "php.ini.erb"
      mode 0644
      owner "root"
      group "root"
      variables(conf)
      notifies :reload, "service[apache2]", :delayed
    end
  end
end
