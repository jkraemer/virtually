require 'virtually'
require 'virtually/xml_thing'

module Virtually

  class Disk < XmlThing
    # type of the underlying source, usually block or file.
    def type
      xpath '.', 'type'
    end

    # type of this disk as seen by the guest, 'disk', 'cdrom', 'floppy'
    # are common values.
    def device
      xpath '.', 'device'
    end

    # source - the file or device on the host that contains the data
    # for this disk.
    def source
      case type
      when 'block'
        xpath 'source', 'dev'
      when 'file'
        xpath 'source', 'file'
      else
        raise "unknown source type #{type}"
      end
    end

    # logical device name as seen by the guest, i.e. 'vda' or 'hda'
    def target_dev
      xpath 'target', 'dev'
    end

    # type of emulated disk device, i.e. 'ide' or 'virtio'
    def target_bus
      xpath 'target', 'bus'
    end
  end

end
