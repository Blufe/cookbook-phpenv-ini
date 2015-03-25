#
# Cookbook Name:: module
# Recipe:: setup_phpredis
#
# Copyright 2015, higashi.ryohei@nifty.co.jp
#
# All rights reserved - Do Not Redistribute
#

include_recipe "redisio"
include_recipe "redisio::enable"
include_recipe "phpenv"
include_recipe "module::install_phpredis"
include_recipe "module::configure_phpredis"
