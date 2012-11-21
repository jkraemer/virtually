require 'virtually'
require 'virtually/xml_thing'

module Virtually
  class NetworkInterface < XmlThing
    def initialize(node, domain)
      super node
      @domain = domain
    end

    def ip
      @domain.ip(mac)
    end

    def mac
      xpath 'mac', 'address'
    end

    # name of the network configuration this device is using
    # use hypervisor.find_network(name) to get a handle to the actual
    # network config.
    def network
      xpath 'source', 'network'
    end
  end
end
