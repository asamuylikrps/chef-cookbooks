define :score_app do
	app_config = params[:app_config]

	# Set up the Apache virtual host 
	web_app app_config['name'] do 
	  server_name app_config['server_name']
	  server_aliases app_config['server_aliases']
	  docroot app_config['docroot']
	  template "scoreapp.conf.erb"
	  log_dir app_config['log_dir']
	end

	#
	# Set up the local application config.
	# This part is most likely to be different for different applications.
	#
	directory "#{app_config['config_dir']}" do
	  owner "root"
	  group "root"
	  mode "0755"
	  action :create
	  recursive true
	end

	directory "#{app_config['log_dir']}" do
	  owner node['apache']['user']
	  group "root"
	  mode "0777"
	  action :create
	  recursive true
	end

	file "#{app_config['log_dir']}/general.log" do
	  owner node['apache']['user']
	  group node['apache']['group']
	  mode "0644"
	  action :create
	end

	template "#{app_config['config_dir']}/config.properties" do
	  source "config.properties.erb"
	  mode "0440"
	  owner "root"
	  group node['apache']['group']
	  variables(
	    'params' => {
	      'log_dir' => app_config['log_dir'],
	      'app_name' => app_config['name'],
	      'docroot' => app_config['docroot'],
	      'environment' => 'PROD',
	    } 
	  )
	end
end