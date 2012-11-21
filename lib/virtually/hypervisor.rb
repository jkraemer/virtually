require 'net/ssh'

require 'virtually/pool'
require 'virtually/domain'
require 'virtually/network'

module Virtually
  class Hypervisor
    include SSH

    attr_reader :connection, :ssh_user
    def initialize(connection, options = {})
      @ssh_user = options[:ssh_user]
      @connection = connection
    end

    def find_ip(mac)
      if ip = run(ip_command(mac))
        ip.strip
      else
        false
      end
    end

    # shell command to be run on the hypervisor that will output the IP for the
    # given mac address.
    def ip_command(mac)
      %{grep #{mac} /var/log/arpwatch.log | tail -1 | awk '{ print $(NF-4) ~ /new/ ? $(NF-2) : $(NF-3) }'}
    end

    # returns the Libvirt::Connect::Nodeinfo instance for the Hypervisor node.
    def info
      connection.node_get_info
    end

    def hostname
      connection.hostname
    end

    # domain stuff

    # ids of running domains
    def active_domain_ids
      connection.list_domains
    end

    # names of not running domains
    def inactive_domain_names
      connection.list_defined_domains
    end

    # get a currently active domain by id
    def find_domain_by_id(id)
      Domain.new connection.lookup_domain_by_id(id), self
    rescue Libvirt::RetrieveError
    end

    # get a domain by name
    def find_domain_by_name(name)
      Domain.new connection.lookup_domain_by_name(name), self
    rescue Libvirt::RetrieveError
    end

    # define a permanent domain
    def define_domain(options = {})
      xml = Domain.to_xml options
      Domain.new connection.define_domain_xml(xml), self
    end

    # create a transient domain
    def create_domain(options = {})
      xml = Domain.to_xml options
      Domain.new connection.create_domain_xml(xml), self
    end

    # storage

    # list of all storage pool names
    def storage_pool_names
      @storage_pools ||= connection.list_storage_pools
    end

    # storage pool object
    def find_storage_pool(name)
      Pool.new connection.lookup_storage_pool_by_name(name)
    end

    # first pool of the host
    def default_storage_pool
      if storage_pool_names.any?
        find_storage_pool storage_pool_names.first
      end
    end

    def find_network(name)
      Network.new connection.lookup_network_by_name(name)
    end

    # disconnects from the host. this instance will become unuseable after
    # calling this method.
    def close
      connection.close
      @connection = nil
    end

  end
end
