module Chip8
  module DisplayProtocol
    abstract def set_pixel(x : UInt32, y : UInt32, value : Bool) : Bool
    abstract def clear : Nil
  end
end
