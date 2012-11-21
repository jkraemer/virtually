require 'libvirt'
require 'virtually/hypervisor'

module Virtually

  class << self

    # Returns a new Hypervisor instance, connected to the given URI
    #
    # options are:
    #    ssh_user - username to use for ssh access of the hypervisor (used for
    #    getting guest IP addresses), defaults to root
    def connect(uri, options = {})
      options = options.merge :ssh_user => 'root'
      return Hypervisor.new(Libvirt::open(uri), options)
    end

  end

end

