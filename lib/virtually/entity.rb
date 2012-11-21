require 'virtually'
require 'virtually/xml_thing'
require 'virtually/erb_renderer'

module Virtually

  class Entity < XmlThing

    KB = 1024
    MB = 1024*KB
    GB = 1024*MB

    attr_reader :wrapped_object

    def initialize(libvirt_object)
      @wrapped_object = libvirt_object
    end

    def xml
      @xml ||= Nokogiri::XML(wrapped_object.xml_desc)
    end

    # Returns the XML with values from binding filled in.
    def self.to_xml(attributes = {})
      ErbRenderer.new(attributes).render(template_path)
    end

    def self.connection
      Virtually.connection
    end

    def self.delegate(*methods)
      methods.each do |m|
        define_method m do
          wrapped_object.send m
        end
      end
    end

    protected

    def wrapped_object=(obj)
      @wrapped_object = obj
      @xml = nil
    end

    # By default, XML templates are looked up in
    # GEM_HOME/templates/classname.xml.erb
    #
    # override to supply custom templates
    def self.template_path
      File.join(File.dirname(__FILE__), "../../templates/#{template_name}")
    end

    # override to implement a custom template naming scheme.
    def self.template_name
      "#{self.name.downcase.gsub /.*::/, ''}.xml.erb"
    end

  end

end
