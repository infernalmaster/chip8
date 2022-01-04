require "crsfml"
require "crsfml/audio"

module Chip8
  class Speaker
    def initialize
      samples = (0..44100).map do |i|
        sine_wave(i.to_f32, 440_f32, 0.9_f32)
      end

      buffer = SF::SoundBuffer.from_samples(samples, 1, 44100)

      @sound = SF::Sound.new(buffer)
      @sound.loop = true
    end

    def play
      @sound.play
    end

    def stop
      @sound.stop
    end

    private def sine_wave(time : Float32, freq : Float32, amp : Float32) : Int16
      tpc = 44100_f32 / freq
      cycles = time / tpc
      rad = cycles * Math::PI * 2
      amplitude = amp * 32767

      (Math.sin(rad) * amplitude).to_i16
    end
  end
end
