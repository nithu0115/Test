include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  
  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end
  
  execute "cd /srv/www/smpp/current/SMPPServer ;  make" do
    Chef::Log.info("Make SMPP Server")
  end
  
  execute "cd /srv/www/smpp/current/SMPPServer ; sh run.sh" do
    Chef::Log.info("Run SMPP Server")
  end
end
