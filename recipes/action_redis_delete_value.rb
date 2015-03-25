#
# Cookbook Name:: module
# Recipe:: action_redis_delete_value
#
# Copyright 2015, higashi.ryohei@nifty.co.jp
#
# All rights reserved - Do Not Redistribute
#

node["redis-cli"]["keys"].each do |key|
  bash "redis-cli del #{key}" do
    user  "root"
    group "root"
    code  "redis-cli keys '#{key}' | xargs redis-cli del"
  end
end
