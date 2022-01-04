require "./display_protocol"
require "./keyboard_protocol"

module Chip8
  class CPU
    # Memory - 4kb (4096 bytes) memory storage (8-bit)
    # I - stores memory addresses
    # PC - Program Counter (8-bit) stores currently executing address
    property memory = StaticArray(UInt8, 4048).new(0)
    property i = 0_u16
    property pc = 0x200_u16

    # V - registers (16 * 8-bit) V0 through VF; VF is a flag
    property v = StaticArray(UInt8, 16).new(0)

    # Stack - (16 * 16-bit)
    # SP - Stack Pointer (8-bit) points at top level of stack
    property stack = StaticArray(UInt16, 16).new(0)
    property sp = -1_i8

    # ST - Sound Timer (8-bit)
    # DT - Delay Timer (8-bit)
    property st = 0_u8
    property dt = 0_u8

    property display : Display
    property keyboard : Keyboard

    def initialize(@display : DisplayProtocol, @keyboard : KeyboardProtocol)
      load_font
    end

    def load(io)
      index = 0x200
      io.each_byte do |byte|
        memory[index] = byte
        index += 1
      end
    end

    def reset
      @memory.fill(0)
      load_font
      @i = 0_u16
      @pc = 0x200_u16
      @v.fill(0)
      @stack.fill(0)
      @sp = -1_i8
      @st = 0_u8
      @dt = 0_u8

      display.clear
    end

    def load_font
      80.times do |i|
        memory[i] = FONT_SET[i]
      end
    end

    # 60 Hz
    def decrement_timers
      if st > 0
        self.st -= 1
      end

      if dt > 0
        self.dt -= 1
      end
    end

    # 500 Hz
    def execute_cycle
      process_opcode(read_opcode)
    end

    def read_opcode : UInt16
      (memory[pc].to_u16 << 8) | memory[pc + 1].to_u16
    end

    def process_opcode(opcode : UInt16)
      op0 = opcode >> 12
      op1 = (opcode >> 8) & 0x0F
      op2 = (opcode >> 4) & 0x00F
      op3 = opcode & 0x000F

      x = (opcode & 0x0F00) >> 8
      y = (opcode & 0x00F0) >> 4
      v[y] = v[y]

      nnn = opcode & 0x0FFF
      kk = (opcode & 0x00FF).to_u8
      n = (opcode & 0x000F).to_u8

      @pc += 2

      case {op0, op1, op2, op3}
      when {0, 0, 0xE, 0} # 00E0 - CLS
        display.clear
      when {0, 0, 0xE, 0xE} # 00EE - RET
        raise "stack underflow" if sp == -1
        @pc = stack[sp]
        @sp -= 1
      when {0x1, _, _, _} # 1nnn - JP addr
        @pc = nnn
      when {0x2, _, _, _} # 2nnn - CALL addr
        raise "stack underflow" if sp === 15
        @sp += 1
        stack[sp] = pc
        @pc = nnn
      when {0x3, _, _, _} # 3xkk - SE Vx, byte
        @pc += 2 if v[x] == kk
      when {0x4, _, _, _} # 4xkk - SNE Vx, byte
        @pc += 2 if v[x] != kk
      when {0x5, _, _, _} # 5xy0 - SE Vx, Vy
        @pc += 2 if v[x] == v[y]
      when {0x6, _, _, _} # 6xkk - LD Vx, byte
        v[x] = kk
      when {0x7, _, _, _} # 7xkk - ADD Vx, byte
        v[x] = v[x] &+ kk
      when {0x8, _, _, 0x0} # 8xy0 - LD Vx, Vy
        v[x] = v[y]
      when {0x8, _, _, 0x1} # 8xy1 - OR Vx, Vy
        v[x] = v[x] | v[y]
      when {0x8, _, _, 0x2} # 8xy2 - AND Vx, Vy
        v[x] = v[x] & v[y]
      when {0x8, _, _, 0x3} # 8xy3 - XOR Vx, Vy
        v[x] = v[x] ^ v[y]
      when {0x8, _, _, 0x4} # 8xy4 - ADD Vx, Vy
        v[0xf] = v[x].to_u16 + v[y].to_u16 > 256 ? 1_u8 : 0_u8
        v[x] = v[x] &+ v[y]
      when {0x8, _, _, 0x5} # 8xy5 - SUB Vx, Vy
        v[0xf] = v[x] > v[y] ? 1_u8 : 0_u8
        v[x] = v[x] &- v[y]
      when {0x8, _, _, 0x6} # 8xy6 - SHR Vx {, Vy}
        v[0xf] = v[x].bit(0) > 0 ? 1_u8 : 0_u8
        v[x] = v[x] >> 1
      when {0x8, _, _, 0x7} # 8xy7 - SUBN Vx, Vy
        v[0xf] = v[y] > v[x] ? 1_u8 : 0_u8
        v[x] = v[y] &- v[x]
      when {0x8, _, _, 0xE} # 8xyE - SHL Vx {, Vy}
        v[0xf] = v[x].bit(7) > 0 ? 1_u8 : 0_u8
        v[x] = v[x] << 1
      when {0x9, _, _, 0x0} # 9xy0 - SNE Vx, Vy
        @pc += 2 if v[x] != v[y]
      when {0xA, _, _, _} # Annn - LD I, addr
        @i = nnn
      when {0xB, _, _, _} # Bnnn - JP V0, addr
        @pc = nnn + v[0x0]
      when {0xC, _, _, _} # Cxkk - RND Vx, byte
        v[x] = Random.rand(256).to_u8 & kk
      when {0xD, _, _, _} # Dxyn - DRW Vx, Vy, nibble
        v[0xf] = 0_u8

        n.times do |byte_index|
          byte = memory[i + byte_index]

          8.times do |bit_index|
            if display.set_pixel(
                 v[x].to_u + bit_index,
                 v[y].to_u + byte_index,
                 byte.bit(7 - bit_index) > 0
               )
              v[0xf] = 1_u8
            end
          end
        end
      when {0xE, _, 0x9, 0xE} # Ex9E - SKP Vx
        @pc += 2 if keyboard.is_key_pressed(v[x])
      when {0xE, _, 0xA, 0x1} # ExA1 - SKNP Vx
        @pc += 2 if !keyboard.is_key_pressed(v[x])
      when {0xF, _, 0x0, 0x7} # Fx07 - LD Vx, DT
        v[x] = dt
      when {0xF, _, 0x0, 0xA} # Fx0A - LD Vx, K
        @pc -= 2
        key = keyboard.get_pressed_key
        if !key.nil?
          @pc += 2
          v[x] = key
        end
      when {0xF, _, 0x1, 0x5} # Fx15 - LD DT, Vx
        @dt = v[x]
      when {0xF, _, 0x1, 0x8} # Fx18 - LD ST, Vx
        @st = v[x]
      when {0xF, _, 0x1, 0xE} # Fx1E - ADD I, Vx
        @i += v[x].to_u16
      when {0xF, _, 0x2, 0x9} # Fx29 - LD F, Vx
        # sprite consists of 5 bytes
        @i = v[x].to_u16 * 5
      when {0xF, _, 0x3, 0x3} # Fx33 - LD B, Vx
        memory[i] = (v[x] / 100).to_u8
        memory[i + 1] = (v[x] / 100).to_u8 % 10_u8
        memory[i + 2] = v[x] % 10_u8
      when {0xF, _, 0x5, 0x5} # Fx55 - LD [I], Vx
        (x + 1).times do |index|
          memory[i + index] = v[index]
        end
      when {0xF, _, 0x6, 0x5} # Fx65 - LD Vx, [I]
        (x + 1).times do |index|
          v[index] = memory[i + index]
        end
      else
        raise "Unknown instruction"
      end
    end
  end
end
