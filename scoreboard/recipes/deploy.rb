#
# Cookbook Name:: scoreboard
# Recipe:: deploy
#
# Copyright 2013, Remedy Point Solutions, Inc.
#
# All rights reserved - Do Not Redistribute
#

include_recipe "scoreboard::webserver"

# Deploy application from repo
apps = node['apps']
if !apps.empty?
  apps.each do |app|
    score_deploy do
      app_config app
    end
  end
end