require 'test_helper'
require 'virtually'
require 'virtually/hypervisor'

module Virtually
  class ConnectionTest < Test::Unit::TestCase

    test "should connect" do
      assert host = Virtually.connect(CONFIG[:uri])
      assert Hypervisor === host
      assert conn = host.connection
      assert host.info
      assert host.hostname.length > 0
    end

  end
end
