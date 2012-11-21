require 'test_helper'
require 'virtually/pool'
require 'virtually/volume'

module Virtually
  class PoolTest < Test::Unit::TestCase
    include TestHelper

    def setup
      @host ||= connect
      @pool ||= @host.find_storage_pool(CONFIG[:test_pool])
    end

    test "should create and find volume" do
      name = "test-#{Time.now.to_i}"
      assert !@pool.volume_names.include?(name)

      assert v = @pool.create_volume(:name => name, :capacity => 1)
      assert v.is_a?(Volume)
      assert_equal name, v.name
      assert_equal Volume::GB, v.capacity
      assert_equal "#{@pool.path}/#{name}", v.path

      assert @pool.volume_names.include?(name)

      assert v2 = @pool.find_volume(name)
      assert_equal v.path, v2.path
      v.destroy
      assert !@pool.volume_names.include?(name)
    end

    test "should should return nil for non existing volume" do
      assert_nil @pool.find_volume('foobar')
    end

  end
end
