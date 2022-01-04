module Chip8
  module KeyboardProtocol
    abstract def is_key_pressed(key : UInt8) : Bool
    abstract def get_pressed_key : UInt8?
  end
end
