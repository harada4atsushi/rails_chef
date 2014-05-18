VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "CentOS-6.5-x86_64-minimal"

  config.omnibus.chef_version = :latest

  config.vm.provision :chef_solo do |chef|
    chef.log_level = :debug
    chef.cookbooks_path = ["./berks-cookbooks", "./site-cookbooks" ]
    chef.json = {
      rbenv: {
        rubies: ["2.1.1"],
        global: "2.1.1"
      },
      nginx_passenger: {
        nginx_ver: "1.6.0",
        passenger_ver: "4.0.42"
      }
    }
    chef.run_list = [
      "vim",
      "ruby_build",
      "rbenv::system",
      "iptables",
      "rails_chef::nginx_passenger",
      "rails_chef"
    ]
  end

  # localhost:10080にアクセスするとゲストOSの80に転送させる
  config.vm.network :forwarded_port, host: 10080, guest: 80

  # debugのためにwebrickの3000番もあけておく
  config.vm.network :forwarded_port, host: 13000, guest: 3000

  # ssh-agentに登録されているキーをゲストOSからもそのまま使えるようにする
  config.ssh.forward_agent = true
end
