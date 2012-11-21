require 'erb'
require 'ostruct'

module Virtually

  class ErbRenderer < OpenStruct
    def render(template_path)
      ERB.new(File.read(template_path), nil, '-').result(binding)
    end
  end

end
