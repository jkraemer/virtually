require 'nokogiri'
require 'virtually'

module Virtually

  # Base class for Objects based on Libvirt XML data
  class XmlThing
    def initialize(xml)
      if String === xml
        self.xml = xml
      else
        @xml = xml
      end
    end

    protected

    def xml=(xml)
      @xml_data = xml
    end

    def xml
      @xml ||= Nokogiri::XML(@xml_data)
    end

    # xml value / attribute retrieval
    def xpath(path, attribute = nil)
      if e = xml.xpath(path).first
        return attribute.nil? ? e.text : e[attribute]
      end
    end
  end

end
