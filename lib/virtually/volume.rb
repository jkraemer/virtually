require 'virtually/entity'
require 'virtually/pool'

module Virtually
  class Volume < Entity

    alias volume wrapped_object
    attr_reader :pool

    def initialize(volume, pool)
      super volume
      @pool = pool
    end

    # valid options are :name and :pool in case you want to clone to another
    # pool
    # returns the newly created volume instance
    def clone(options)
      target_pool = options[:pool] || self.pool
      xml = self.class.to_xml(:name => options[:name], :capacity => self.capacity)
      Volume.new target_pool.pool.create_volume_xml_from(xml, self.volume), target_pool
    end

    # deletes this volume
    def destroy
      volume.delete
      true
    end

    def name
      xpath 'volume/name'
    end

    def path
      xpath 'volume/target/path'
    end

    def key
      xpath 'volume/key'
    end

    def capacity
      xpath('volume/capacity').to_i
    end

  end
end
