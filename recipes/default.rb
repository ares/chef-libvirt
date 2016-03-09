case node[:platform]
  when 'debian', 'ubuntu'
    %w(libvirt-bin libvirt-dev).each do |name|
      package name do
        action :nothing
      end.run_action(:install)
    end

  when 'redhat', 'centos', 'fedora'
    %w(qemu-kvm libvirt virt-manager bridge-utils libvirt-devel libvirt-daemon-kvm libvirt-daemon-config-network).each do |name|
      package name do
        action :nothing
      end.run_action(:install)
    end

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
  
%w(ruby-libvirt uuidtools).each do |name|
  chef_gem name do
    action :install
  end
end

$LOAD_PATH.delete("/usr/bin/../lib") # scumbag LOAD_PATH: https://github.com/opscode/chef/blob/master/bin/chef-solo#L22
require 'libvirt'
