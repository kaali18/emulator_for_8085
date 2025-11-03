import 'memory.dart';

class Flags {
  bool s = false; // Sign Flag
  bool z = false; // Zero Flag
  bool ac = false; // Auxiliary Carry Flag
  bool p = false; // Parity Flag
  bool cy = false; // Carry Flag

  int get psw {
    int value = 0;
    if (s) value |= 0x80;
    if (z) value |= 0x40;
    if (ac) value |= 0x10;
    if (p) value |= 0x04;
    if (cy) value |= 0x01;
    return value;
  }

  set psw(int value) {
    s = (value & 0x80) != 0;
    z = (value & 0x40) != 0;
    ac = (value & 0x10) != 0;
    p = (value & 0x04) != 0;
    cy = (value & 0x01) != 0;
  }

  void reset() {
    s = z = ac = p = cy = false;
  }
}

class CPU {
  // Registers
  int a = 0, b = 0, c = 0, d = 0, e = 0, h = 0, l = 0;
  int sp = 0xFFFF;
  int pc = 0x0000;

  // Flags
  final flags = Flags();

  // Memory
  final Memory memory;

  bool halted = false;

  CPU(this.memory);

  void reset() {
    a = b = c = d = e = h = l = 0;
    sp = 0xFFFF;
    pc = 0x0000;
    flags.reset();
    halted = false;
  }

  int get bc => (b << 8) | c;
  set bc(int value) {
    b = (value >> 8) & 0xFF;
    c = value & 0xFF;
  }

  int get de => (d << 8) | e;
  set de(int value) {
    d = (value >> 8) & 0xFF;
    e = value & 0xFF;
  }

  int get hl => (h << 8) | l;
  set hl(int value) {
    h = (value >> 8) & 0xFF;
    l = value & 0xFF;
  }

  // Step execution
  void step() {
    if (halted) return;

    final opcode = memory[pc];
    pc = (pc + 1) & 0xFFFF;
    _execute(opcode);
  }

  void _execute(int opcode) {
    // This will be a giant switch statement for all 256 opcodes.
    // For now, let's implement a few.
    switch (opcode) {
      // NOP
      case 0x00:
        break;

      // HLT
      case 0x76:
        halted = true;
        break;

      // MVI A, d8
      case 0x3E:
        a = memory[pc];
        pc = (pc + 1) & 0xFFFF;
        break;
      
      // MVI B, d8
      case 0x06:
        b = memory[pc];
        pc = (pc + 1) & 0xFFFF;
        break;

      // ADD B
      case 0x80:
        _add(b);
        break;

      // SUB B
      case 0x90:
        _sub(b);
        break;

      // LXI B, d16
      case 0x01:
        c = memory[pc];
        b = memory[(pc + 1) & 0xFFFF];
        pc = (pc + 2) & 0xFFFF;
        break;

      // JMP addr
      case 0xC3:
        final low = memory[pc];
        final high = memory[(pc + 1) & 0xFFFF];
        pc = (high << 8) | low;
        break;

      // Default for unimplemented opcodes
      default:
        // For now, do nothing for unknown opcodes
        break;
    }
  }

  void _add(int value) {
    int result = a + value;
    flags.cy = result > 0xFF;
    flags.ac = (a & 0x0F) + (value & 0x0F) > 0x0F;
    a = result & 0xFF;
    _updateFlags(a);
  }

  void _sub(int value) {
    int result = a - value;
    flags.cy = result < 0;
    // Note: AC for subtraction is complex, this is a simplification
    flags.ac = (a & 0x0F) < (value & 0x0F);
    a = result & 0xFF;
    _updateFlags(a);
  }

  void _updateFlags(int result) {
    flags.z = result == 0;
    flags.s = (result & 0x80) != 0;
    flags.p = _calculateParity(result);
  }

  bool _calculateParity(int value) {
    int count = 0;
    for (int i = 0; i < 8; i++) {
      if ((value & (1 << i)) != 0) {
        count++;
      }
    }
    return count % 2 == 0;
  }
}
