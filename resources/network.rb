actions :define, :create, :autostart

def initialize(*args)
  super
  @action = :define
end

attribute :bridge, :kind_of => String
attribute :netmask, :kind_of => String
attribute :gateway, :kind_of => String
attribute :forward, :kind_of => String
attribute :domain, :kind_of => String
attribute :tftp, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :dns_a_records, :kind_of => Hash, :default => {}
attribute :dhcp_range, :kind_of => Hash
attribute :uri, :kind_of => String, :default => 'qemu:///system'
