require 'test_helper'
require 'virtually/hypervisor'

module Virtually
  class HypervisorTest < Test::Unit::TestCase
    include TestHelper

    def setup
      @host ||= connect
    end

    test "should run command on hypervisor" do
      assert hostname = @host.run('hostname')
      assert_match /#{hostname.strip}/, @host.hostname
    end

    test "should get pool list" do
      assert pool_names = @host.storage_pool_names
      assert pool_names.include?(CONFIG[:test_pool])
    end

    test "should find pool by name" do
      assert pool = @host.find_storage_pool(CONFIG[:test_pool])
      assert pool.is_a?(Pool)
      assert_equal CONFIG[:test_pool], pool.name
      assert_match /#{CONFIG[:test_pool]}$/, pool.path
    end

    test "should find default pool" do
      assert pool = @host.default_storage_pool
      assert pool.name
      assert pool.name.length > 0
      assert pool.path
      assert pool.path.length > 0
      assert @host.storage_pool_names.include? pool.name
    end

    test "should get inactive domain name list" do
      assert domains = @host.inactive_domain_names
      assert domains.any?
    end

    test "should get active domain ids" do
      assert ids = @host.active_domain_ids
      assert ids.any?
    end

    test "should get domain" do
      assert dom = @host.find_domain_by_name(CONFIG[:test_domain])
      assert_equal 1, dom.vcpu
      assert_equal 512*Entity::MB, dom.memory
      assert dom.name.length > 0
      assert_equal 1, dom.network_interfaces.size
      assert_equal 17, dom.network_interface.mac.length
      assert_equal 1, dom.disks.size
      assert disk = dom.disk
      assert_equal 'disk', disk.device
      assert_equal 'block', disk.type
      assert disk.source.length > 0
      assert_equal 'virtio', disk.target_bus
      assert_equal 'vda', disk.target_dev
    end

    test "should create domain with existing volume" do
      assert pool = @host.find_storage_pool(CONFIG[:test_pool])
      assert vol = pool.find_volume(CONFIG[:test_volume])
      options = {
        :name => "test-dom-#{Time.now.to_i}",
        :disk => {
          :source => vol.path
        }
      }
      (File.new('test-domain.xml', 'w') << Domain.to_xml(options)).close
      assert dom = @host.create_domain(options)
      sleep 1
      assert dom.active?
      assert mac = dom.network_interface.mac
      t = 0
      ip = nil
      begin
        sleep 0.5
        t += 1
        ip = dom.ip
      end until ip || t > 20
      assert ip
      assert ip.length > 6
      dom.shutdown(true)
    end

    test "should find default network" do
      assert n = @host.find_network('default')
      assert_equal 'default', n.name
    end

  end
end

