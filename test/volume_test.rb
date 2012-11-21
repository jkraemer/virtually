require 'test_helper'
require 'virtually'
require 'virtually/volume'

module Virtually
  class VolumeTest < Test::Unit::TestCase
    include TestHelper

    def setup
      @host ||= connect
      @pool ||= @host.find_storage_pool(CONFIG[:test_pool])
    end

    test "should build xml" do
      xml = Volume.to_xml(:name => 'test', :capacity => 1)
      assert_match />test<\/name>/, xml
      assert_match />1<\/capacity>/, xml
    end

    test "should clone volume" do
      name = "testvol-#{Time.now.to_i}"
      volume = @pool.create_volume :name => name, :capacity => 1
      assert_equal name, volume.name

      assert clone = volume.clone(:name => "#{name}-clone")
      assert clone.is_a?(Volume)
      assert @pool.volume_names.include?("#{name}-clone")

      assert volume.destroy
      assert clone.destroy
    end

  end
end

