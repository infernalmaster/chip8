require "crsfml"

require "../display_protocol"

module Chip8
  class Display
    include DisplayProtocol

    property window
    WIDTH            = 64
    HEIGHT           = 32
    SCALE            = 30                      # pixel size
    BUFFER_SIZE      = 64 * 32                 # WIDTH * HEIGHT
    BACKGROUND_COLOR = SF.color(64, 62, 68)    # SF::Color::Black
    PRIMRY_COLOR     = SF.color(255, 231, 177) # SF::Color::Green

    def initialize
      @window = SF::RenderWindow.new(SF::VideoMode.new(WIDTH * SCALE, HEIGHT * SCALE), "Chip8")
      @buffer = StaticArray(Bool, BUFFER_SIZE).new(false)
    end

    def set_pixel(x : UInt32, y : UInt32, value : Bool) : Bool
      index = (x % WIDTH) + (y % HEIGHT) * WIDTH
      collision = @buffer[index] & value

      @buffer[index] = @buffer[index] ^ value

      collision
    end

    def clear : Nil
      @buffer.fill(false)
    end

    def draw
      window.clear(BACKGROUND_COLOR)

      HEIGHT.times do |y|
        WIDTH.times do |x|
          index = x + y * WIDTH

          next if !@buffer[index]

          shape = SF::RectangleShape.new(SF.vector2(SCALE, SCALE))
          shape.position = SF.vector2(x * SCALE, y * SCALE)
          shape.fill_color = PRIMRY_COLOR
          window.draw(shape)
        end
      end

      window.display
    end
  end
end
