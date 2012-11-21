module Virtually
  module Autostart

    def autostart?
      wrapped_object.autostart?
    end

    # turn autostart on or off
    def autostart=(boolean)
      wrapped_object.autostart = boolean
    end

  end
end
