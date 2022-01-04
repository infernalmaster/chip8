require "crsfml"

require "../keyboard_protocol"

module Chip8
  class Keyboard
    include KeyboardProtocol

    # 1	2	3	C
    # 4	5	6	D
    # 7	8	9	E
    # A	0	B	F
    KEY_MAP = {
      0x1_u8 => SF::Keyboard::Num1,
      0x2_u8 => SF::Keyboard::Num2,
      0x3_u8 => SF::Keyboard::Num3,
      0xc_u8 => SF::Keyboard::Num4,

      0x4_u8 => SF::Keyboard::Q,
      0x5_u8 => SF::Keyboard::W,
      0x6_u8 => SF::Keyboard::E,
      0xd_u8 => SF::Keyboard::R,

      0x7_u8 => SF::Keyboard::A,
      0x8_u8 => SF::Keyboard::S,
      0x9_u8 => SF::Keyboard::D,
      0xe_u8 => SF::Keyboard::F,

      0xA_u8 => SF::Keyboard::Z,
      0x0_u8 => SF::Keyboard::X,
      0xB_u8 => SF::Keyboard::C,
      0xF_u8 => SF::Keyboard::V,
    }

    def is_key_pressed(key : UInt8) : Bool
      SF::Keyboard.key_pressed?(KEY_MAP[key])
    end

    def get_pressed_key : UInt8?
      KEY_MAP.each_key.find do |key|
        is_key_pressed(key)
      end
    end
  end
end
