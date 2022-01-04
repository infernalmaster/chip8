module Chip8
  VERSION = "0.1.0"

  Main.new
end

require "./font_set"
require "./devices/display"
require "./devices/keyboard"
require "./devices/speaker"
require "./cpu"
require "./main"
