require 'virtually/entity'
require 'virtually/autostart'
require 'virtually/ssh'
require 'virtually/disk'
require 'virtually/network_interface'

module Virtually

  # TODO
  # - snapshotting
  # - migration
  # - screenshot
  class Domain < Entity
    include Autostart
    include SSH

    alias domain wrapped_object

    attr_accessor :ssh_user


    def initialize(domain, host)
      super domain
      @host = host
      @ssh_user = host.ssh_user
    end

    # default config for new domains:
    # 1GB RAM, 1 CPU, x86_64, en-us keymap in VNC
    def self.default_domain_config
      {
        :type => 'kvm',
        :memory => 1,
        :vcpu => 1,
        :arch => 'x86_64',
        :virt_type => 'hvm',
        :vnc_keymap => 'en-us',
        :disks => [ default_disk ],
        :network_interfaces => [ default_network_interface ]
      }
    end

    # default network interface - virtio connected to 'default' network
    def self.default_network_interface
      { :network => 'default', :type => 'virtio' }
    end

    # default disk config - virtio block devices
    def self.default_disk
      { :type => 'block', :device => 'disk', :target_dev => 'vda', :target_bus => 'virtio' }
    end

    # Create libvirt domain definition xml from given options.
    #
    # At the very least you have to specify the :name and :disk[:source]
    # elements.
    def self.to_xml(options = {})
      options = options.dup
      options[:disks] = [options.delete(:disk)] if options[:disk]
      options[:network_interfaces] = [options.delete(:network_interface)] if options[:network_interface]

      options = default_domain_config.merge options
      options[:disks] = options[:disks].map {|n|
        default_disk.merge n
      }
      options[:network_interfaces] = options[:network_interfaces].map {|n|
        default_network_interface.merge n
      }
      options[:disks] = options[:disks]
      options[:memory] = options[:memory] * GB if options[:memory] < 100000
      super options
    end

    # DOMAIN LIFECYCLE
    delegate :suspend, :resume, :destroy, :reboot, :undefine,
      :state, :persistent?

    def active?
      domain.active? rescue false
    end

    def create(block = false)
      domain.create
      if block
        begin
          sleep 0.5
        end until active?
        reload
      end
    end
    alias start create

    TIMEOUT = 30
    def shutdown(block = false)
      is_persistent = domain.persistent?
      domain.shutdown
      if block
        time = 0
        begin
          sleep 0.5
          time += 0.5
        end while active? && time < TIMEOUT
        begin
          reload
          return !active?
        rescue Libvirt::RetrieveError
          return is_persistent # non persistent domains disappear after successful shutdown and cannot be reloaded
        end
      end
    end

    # saves domain state to file
    def save(path)
      domain.save path
    end

    # restores domain state from file
    def restore(path)
      domain.restore path
    end

    # reloads domain state
    def reload
      self.wrapped_object = @host.connection.lookup_domain_by_name(name)
    end


    # DOMAIN ATTRIBUTES


    delegate :name, :uuid, :info

    # domain id if currently running, -1 otherwise
    def id
      domain.id
    rescue Libvirt::RetrieveError
      -1
    end

    def ip(mac = nil)
      mac ||= network_interface.mac
      @host.find_ip(mac)
    end

    # for SSH module
    alias hostname ip 

    # unmber of virtual CPUs
    def vcpu
      xpath('domain/vcpu').to_i
    end

    # architecture
    def arch
      xpath 'domain/os/type', 'arch'
    end

    # RAM size in Bytes
    def memory
      value = xpath('domain/memory').to_i
      case xpath('domain/memory', 'unit')
      when 'KiB'
        value * KB
      when 'MiB'
        value * MB
      when 'GiB'
        value * GB
      else
        value
      end
    end

    # vnc port
    def vnc_port
      xpath('domain/devices/graphics[@type="vnc"]', 'port').to_i
    end

    # shortcut to the first disk
    def disk
      disks.first
    end

    def disks
      [].tap do |disks|
        xml.xpath('domain/devices/disk').each do |node|
          disks << Disk.new(node)
        end
      end
    end

    # shortcut to the first interface
    def network_interface
      network_interfaces.first
    end

    # list of all network interfaces
    def network_interfaces
      [].tap do |network_interfaces|
        xml.xpath('domain/devices/interface[@type="network"]').each do |node|
          network_interfaces << NetworkInterface.new(node, self)
        end
      end
    end
  end
end

