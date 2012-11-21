require 'test_helper'
require 'virtually/entity'

module Virtually
  class XmlTest < Test::Unit::TestCase
    include TestHelper

    def setup
      @domain_xml = IO.read(File.join(File.dirname(__FILE__), 'domain.xml'))
      @xml = XmlThing.new @domain_xml
    end

    test "should extract element value" do
      assert_equal '1', @xml.send(:xpath, 'domain/vcpu')
    end

    test "should extract attribute value" do
      assert_equal 'x86_64', @xml.send(:xpath, 'domain/os/type', 'arch')
    end

  end
end

