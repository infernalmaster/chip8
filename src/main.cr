require "crsfml"

module Chip8
  class Main
    SCREEN_REFRESH_TIME = 1_f32 / 60_f32

    def initialize
      @display = Display.new
      @keyboard = Keyboard.new
      @speaker = Speaker.new
      @cpu = Chip8::CPU.new(@display, @keyboard)

      @font = SF::Font.from_file("./fonts/RobotoMono-Regular.ttf")
      @roms = Dir["./roms/*"]
      @roms.sort!

      @in_menu = true

      @display.window.title = "Buttons: 1234 qwer asdf zxcv; Menu: <Esc>"

      clock = SF::Clock.new
      while @display.window.open?
        handle_events

        if @in_menu
          menu_cycle
        else
          chip_cycle
        end

        # ~ 60fps
        delta = clock.restart.as_seconds
        if delta < SCREEN_REFRESH_TIME
          sleep(SCREEN_REFRESH_TIME - delta)
        end
      end
    end

    def chip_cycle
      # 500Hz
      8.times do
        @cpu.execute_cycle
      end

      # 60Hz
      @cpu.decrement_timers

      if @cpu.st > 0
        @speaker.play
      else
        @speaker.stop
      end

      @display.draw
    rescue ex
      puts ex.message
      @in_menu = true
    end

    def menu_cycle
      @display.window.clear(SF.color(255, 251, 240))

      @roms.each_with_index do |rom, index|
        text = SF::Text.new
        text.font = @font
        text.string = rom.split("/")[-1]
        text.character_size = 36
        text.color = SF.color(64, 62, 68)

        x = index % 8 * (@display.window.size.x.to_f32 / 8_f32).to_i + 40
        y = (index / 8).to_i * (@display.window.size.y.to_f32 / 3_f32).to_i + 50

        text.position = SF.vector2(x, y)

        @display.window.draw(text)
      end

      @display.window.display
    end

    def handle_events
      while event = @display.window.poll_event
        case event
        when SF::Event::Closed
          @display.window.close
        when SF::Event::KeyPressed
          if event.code == SF::Keyboard::Escape
            @in_menu = true
          end
        when SF::Event::MouseButtonPressed
          if @in_menu
            @in_menu = false
            position = SF::Mouse.get_position(@display.window)
            x = (position.x.to_f32 / (@display.window.size.x.to_f32 / 8_f32)).to_i
            y = (position.y.to_f32 / (@display.window.size.y.to_f32 / 3_f32)).to_i
            index = x + y * 8

            File.open(@roms[index]) do |file|
              @cpu.reset
              @cpu.load(file)
            end
          end
        end
      end
    end
  end
end
