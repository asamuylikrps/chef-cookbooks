define :score_deploy do
	app_config = params[:app_config]

	# Handle ssh key for git private repo
	secrets = Chef::EncryptedDataBagItem.load("secrets", "score")
	if secrets["deploy_key"]
	  ruby_block "write_key" do
	    block do
	      f = ::File.open("#{app_config['docroot']}/id_deploy", "w")
	      f.print(secrets["deploy_key"])
	      f.close
	    end
	    not_if do ::File.exists?("#{app_config['docroot']}/id_deploy"); end
	  end

	  file "#{app_config['docroot']}/id_deploy" do
	    mode '0600'
	  end

	  template "#{app_config['docroot']}/git-ssh-wrapper" do
	    source "git-ssh-wrapper.erb"
	    mode "0755"
	    variables("deploy_dir" => app_config['docroot'])
	  end
	end

	deploy_revision app_config['docroot'] do
	  scm_provider Chef::Provider::Git 
	  repo app_config['deploy_repo']
	  revision app_config['deploy_branch']
	  if secrets["deploy_key"]
	    git_ssh_wrapper "#{app_config['docroot']}/git-ssh-wrapper" # For private Git repos
	  end
	  enable_submodules false
	  keep_releases 1
	  shallow_clone true
	  symlink_before_migrate({}) # Symlinks to add before running db migrations
	  purge_before_symlink [] # Directories to delete before adding symlinks
	  create_dirs_before_symlink [] # Directories to create before adding symlinks
	  symlinks({})
	  # migrate true
	  # migration_command "php app/console doctrine:migrations:migrate" 
	  action :deploy

	  before_restart do
	    ["core", "#{app_config['name']}"].each do |folder|
	      execute "copy_#{folder}" do
	        command "cp -R #{app_config['docroot']}/current/#{folder} #{app_config['docroot']} &&
	                chown -R #{node['apache']['user']}:'root' #{app_config['docroot']}/#{folder} &&
	                chmod -R 755 #{app_config['docroot']}/#{folder}"
	      end
	    end
	  end

	  restart_command do
	    service "apache2" do action :restart; end
	  end
	end
end