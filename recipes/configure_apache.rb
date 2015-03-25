#
# Cookbook Name:: module
# Recipe:: configure_control_panel
#
# Copyright 2015, higashi.ryohei@nifty.co.jp
#
# All rights reserved - Do Not Redistribute
#

application_info = node["control_panel"]
application_name = application_info["name"]
apache_conf_dir  = File.join(node["apache"]["dir"], "sites-available")

directory File.join(apache_conf_dir, "#{application_name}.conf.d") do
  owner     "root"
  group     "root"
  recursive true
  mode      0755
  action    :create
  not_if { File.exists?(File.join(apache_conf_dir, "#{application_name}.conf.d")) }
end

%w{
  base
  ssov2
  web
  api
  vmimport
  maintenance
}.each do |conf|
  template File.join(apache_conf_dir, "#{application_name}.conf.d", "#{conf}.conf") do
    source File.join("web_app.conf.d", "#{conf}.conf.erb")
    owner  "root"
    group  "root"
    mode   0644
    action :create
    variables({
       :docroot => application_info["docroot"]
    })
    if ::File.exists?(File.join(apache_conf_dir, "#{application_name}.conf"))
      notifies :reload, "service[apache2]", :delayed
    end
  end
end

web_app application_name do
  template "web_app.conf.erb"
  docroot  application_info["docroot"]
  cookbook "module"
end
