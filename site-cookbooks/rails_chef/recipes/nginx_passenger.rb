
%w{ curl-devel }.each do |pkg|
  package pkg
end


execute 'rbenv rehash' do
  command "rbenv rehash"
end

# passengerをインストール
gem_package 'passenger' do
  version node['nginx_passenger']['passenger_ver']
end

# nginxのソースコードをダウンロード
remote_file 'download nginx' do
  action :create_if_missing
  owner 'root'
  group 'root'
  mode 0644
  path "/tmp/nginx-#{node['nginx_passenger']['nginx_ver']}.tar.gz"
  source "http://nginx.org/download/nginx-#{node['nginx_passenger']['nginx_ver']}.tar.gz"
end

# nginxのソースコードを展開する
execute 'extract nginx' do
  cwd '/tmp'
  command "tar xvfz /tmp/nginx-#{node['nginx_passenger']['nginx_ver']}.tar.gz"
  not_if do
    File.directory? "/tmp/nginx-#{node['nginx_passenger']['nginx_ver']}"
  end
end

# passenger-install-nginx-moduleコマンドを使用してnginxをビルドする
execute 'build nginx' do
  command "passenger-install-nginx-module" <<
    " --auto" <<
    " --prefix=/usr/local/nginx" <<
    " --nginx-source-dir=/tmp/nginx-#{node['nginx_passenger']['nginx_ver']}" <<
    " --extra-configure-flags=--with-http_ssl_module"
  not_if do
    File.exists?("/usr/local/nginx")
  end
end

# nginx設定ファイル用ディレクトリへのシンボリックリンクを作成
link "/etc/nginx" do
  to "/usr/local/nginx/conf"
end

# nginxの共通confファイルを配置
cookbook_file "/etc/nginx/nginx.conf" do
  source "nginx.conf"
end

# アプリケーション個別の設定ファイル格納ディレクトリを作成
directory "/etc/nginx/conf.d" do
  owner "root"
  group "root"
end

# アプリケーション個別のconfファイルを配置
cookbook_file "/etc/nginx/conf.d/sample_rails.conf" do
  source "sample_rails.conf"
  notifies :restart, "service[nginx]"
end

# 起動スクリプトを設置
cookbook_file "/etc/init.d/nginx" do
  source "nginx"
  mode 0755
  not_if "ls /etc/init.d/nginx"
  notifies :run, "execute[chkconfig add nginx]"
end

# 自動起動設定
execute 'chkconfig add nginx' do
  action :nothing
  command "chkconfig --add nginx"
  notifies :run, "execute[chkconfig nginx on]"
  notifies :start, "service[nginx]"
end

execute 'chkconfig nginx on' do
  action :nothing
  command "chkconfig nginx on"
end

service "nginx" do
  action :nothing
end