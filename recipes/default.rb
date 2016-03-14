include_recipe 'build-essential::default'

case node[:platform]
  when 'debian', 'ubuntu'
    %w(libvirt-bin libvirt-dev).each do |name|
      package name do
        action :nothing
      end.run_action(:install)
    end

  when 'redhat', 'centos', 'fedora'
    packages = %w(qemu-kvm libvirt virt-manager bridge-utils libvirt-devel)

    # centos and rhel 7+ provides following packages (works for fedora as well)
    if node[:platform_version].split('.').first.to_i > 6
      packages += %w(libvirt-daemon-kvm libvirt-daemon-config-network)
    end

    packages.each do |name|
      package name do
        action :nothing
      end.run_action(:install)
    end

    if node.platform?('rhel', 'centos', 'fedora') && node[:platform_version].to_i > 6
      # firewall config is only supported on recent rpm based distros atm
      service 'firewalld' do
        action :nothing
      end

      # enable all incoming communication on virbr0 through firewalld but don't touch after modifications
      template '/etc/firewalld/zones/trusted.xml' do
        source 'firewalld_trusted.xml'
        action :create_if_missing
        notifies :reload, 'service[firewalld]', :immediately
      end
    end
end
  
%w(ruby-libvirt uuidtools).each do |name|
  chef_gem name do
    action :install
  end
end

$LOAD_PATH.delete("/usr/bin/../lib") # scumbag LOAD_PATH: https://github.com/opscode/chef/blob/master/bin/chef-solo#L22
require 'libvirt'

service 'libvirtd' do
  action [ :enable, :start ]
end
