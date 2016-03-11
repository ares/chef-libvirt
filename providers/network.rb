require 'uuidtools'

def load_current_resource
  @current_resource = Chef::Resource::LibvirtNetwork.new(new_resource.name)
  @libvirt = ::Libvirt.open(new_resource.uri)
  @network = load_network rescue nil
  @uuid = ::File.read("/etc/libvirt/qemu/networks/#{new_resource.name}_uuid_chef").strip rescue nil
  @uuid ||= ::UUIDTools::UUID.random_create
  @current_resource
end

action :define do
  # if there is already a network with the same name but different uuid than we stored last time
  if !@network.nil? && @uuid != @network.uuid
    @network.destroy
    @network = nil
  end

  uuid = @uuid
  unless network_defined?
    network_xml = Tempfile.new(new_resource.name)
    t = template network_xml.path do
      cookbook "libvirt"
      source   "network.xml"
      variables(
        :name    => new_resource.name,
        :bridge  => new_resource.bridge,
        :netmask => new_resource.netmask,
        :gateway => new_resource.gateway,
        :forward => new_resource.forward,
        :tftp    => new_resource.tftp,
        :domain  => new_resource.domain,
        :dns_a_records => new_resource.dns_a_records,
        :dhcp    => new_resource.dhcp_range,
        :uuid    => uuid
      )
      action :nothing
    end
    t.run_action(:create)

    @libvirt.define_network_xml(::File.read(network_xml.path))

    ::File.write("/etc/libvirt/qemu/networks/#{new_resource.name}_uuid_chef", @uuid)
    @network = load_network
    new_resource.updated_by_last_action(true)
  end
end

action :create do
  require_defined_network
  unless network_active?
    @network.create
    new_resource.updated_by_last_action(true)
  end
end

action :autostart do
  require_defined_network
  unless network_autostart?
    @network.autostart = true
    new_resource.updated_by_last_action(true)
  end
end

private

def load_network
  @libvirt.lookup_network_by_name(new_resource.name)
end

def require_defined_network
  error = RuntimeError.new "You have to define network '#{new_resource.name}' first"
  raise error unless network_defined?
end

def network_defined?
  @network
end

def network_autostart?
  @network.autostart?
end

def network_active?
  @network.active?
end
