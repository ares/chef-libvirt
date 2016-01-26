case node[:platform]
  when 'debian', 'ubuntu'
    %w(libvirt-bin libvirt-dev).each do |name|
      package name do
        action :nothing
      end.run_action(:install)
    end

  when 'redhat', 'centos', 'fedora'
    %w(qemu-kvm libvirt virt-manager bridge-utils libvirt-devel).each do |name|
      package name do
        action :nothing
      end.run_action(:install)
    end
end
  
%w(ruby-libvirt uuidtools).each do |name|
  chef_gem name do
    action :install
  end
end

$LOAD_PATH.delete("/usr/bin/../lib") # scumbag LOAD_PATH: https://github.com/opscode/chef/blob/master/bin/chef-solo#L22
require 'libvirt'
