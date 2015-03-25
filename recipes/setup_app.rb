#
# Cookbook Name:: module
# Recipe:: setup_app
#
# Copyright 2015, higashi.ryohei@nifty.co.jp
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"

include_recipe "module::configure_hosts"
include_recipe "module::configure_route"
include_recipe "module::configure_log"
