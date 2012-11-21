require 'virtually/entity'
require 'virtually/autostart'
require 'virtually/volume'

module Virtually

  # A storage pool.
  #
  # Pools can only be read, not created
  class Pool < Entity
    include Autostart

    alias pool wrapped_object

    # returns the named volume if it is a member of this pool,
    # nil otherwise
    def find_volume(name)
      Volume.new pool.lookup_volume_by_name(name), self
    rescue Libvirt::RetrieveError
      nil
    end

    # returns a list of all volumes of this pool (names only).
    def volume_names
      pool.list_volumes
    end

    # creates a volume with the name and capacity given in options.
    # capacity is assumed to be in GB if less than 100000
    def create_volume(options = {})
      options[:capacity] = options[:capacity] * GB if options[:capacity] < 100000
      vol = pool.create_volume_xml(Volume.to_xml(options))
      Volume.new vol, self
    end

    def name
      xpath "pool/name"
    end

    def path
      xpath "pool/target/path"
    end

  end
end
