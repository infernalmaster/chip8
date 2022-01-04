describe Chip8::CPU do
  describe "#read_opcode" do
    it do
      cpu = Chip8::CPU.new

      cpu.pc = 800
      cpu.memory[800] = 0xF0_u8
      cpu.memory[801] = 0xBF_u8

      cpu.read_opcode.should eq(0xF0BF_u16)
    end
  end

  describe "#load" do
    it do
      cpu = Chip8::CPU.new

      File.open("./roms/MAZE") do |file|
        cpu.load(file)
      end

      cpu.memory.to_slice[512, 34].to_a.should eq(
        [
          162, 30, 194, 1, 50, 1, 162, 26, 208, 20, 112, 4, 48, 64, 18, 0,
          96, 0, 113, 4, 49, 32, 18, 0, 18, 24, 128, 64, 32, 16, 32, 64,
          128, 16,
        ] of UInt8
      )
    end
  end

  describe "#process_opcode" do
    it do
      # display = Mocks.instance_double(Chip8::Display)

      cpu = Chip8::CPU.new

      cpu.process_opcode(0x00E0_u16)

      # display.should have_received(cls())
    end
  end
end
