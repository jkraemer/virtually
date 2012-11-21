require "test/unit"
require "virtually"

module TestHelper

  CONFIG = YAML.load IO.read File.join(File.dirname(__FILE__), 'config.yml')

  def connect
    Virtually.connect CONFIG[:uri], :ssh_user => CONFIG[:ssh_user]
  end

end

class Test::Unit::TestCase
  include TestHelper
end

