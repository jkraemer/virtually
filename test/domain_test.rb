require 'test_helper'
require 'virtually'
require 'virtually/domain'

module Virtually
  class DomainTest < Test::Unit::TestCase
    include TestHelper

    def setup
      @host ||= connect
      @pool ||= @host.find_storage_pool(CONFIG[:test_pool])
      @domain_name = CONFIG[:test_domain]
      assert @domain = @host.find_domain_by_name(@domain_name)
    end

    test "should start and shutdown domain" do
      assert_equal @domain_name, @domain.name
      assert_equal 1, @domain.vcpu
      assert_equal 1, @domain.disks.size
      assert_equal 1, @domain.network_interfaces.size

      @domain.shutdown(true) if @domain.active?

      assert_equal -1, @domain.id
      assert_equal -1, @domain.vnc_port

      @domain.start(true)

      assert @domain.id >= 0
      assert @domain.vnc_port >= 5900

      @domain.shutdown
    end

    test "should toggle autostart" do
      autostart = @domain.autostart?
      @domain.autostart = false
      assert !@domain.autostart?
      @domain.autostart = true
      assert @domain.autostart?
      @domain.autostart = autostart
    end


  end
end

