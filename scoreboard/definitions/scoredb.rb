define :score_db do
  # Create application database
  ruby_block "create_#{params[:name]}_db" do
    block do
      %x[mysql -uroot -p#{node[:mysql][:server_root_password]} -e "CREATE DATABASE #{params[:db_name]};"]
    end 
    not_if "mysql -uroot -p#{node[:mysql][:server_root_password]} -e \"SHOW DATABASES LIKE '#{params[:db_name]}'\" | grep #{params[:db_name]}";
    action :create
  end
  
  # Get a list of web servers
  webservers = node['roles'].include?('webserver') ? [{'ipaddress' => 'localhost'}] : search(:node, "role:webserver AND chef_environment:#{node.chef_environment}")
  
  # Grant mysql privileges for each web server 
  webservers.each do |webserver|
    ip = webserver['ipaddress']
    ruby_block "add_#{ip}_#{params[:name]}_permissions" do
      block do
        %x[mysql -u root -p#{node[:mysql][:server_root_password]} -e "GRANT SELECT,INSERT,UPDATE,DELETE \
          ON #{params[:db_name]}.* TO '#{params[:db_user]}'@'#{ip}' IDENTIFIED BY '#{params[:db_pass]}';"]
      end
      not_if "mysql -u root -p#{node[:mysql][:server_root_password]} -e \"SELECT user, host FROM mysql.user\" | \
        grep #{params[:db_user]} | grep #{ip}"
      action :create
    end
  end
end