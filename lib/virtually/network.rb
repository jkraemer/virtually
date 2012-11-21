require 'virtually/entity'
require 'virtually/autostart'

module Virtually
  class Network < Entity
    include Autostart

    alias network wrapped_object

    delegate :create, :destroy, :undefine, :name, :uuid

  end
end
