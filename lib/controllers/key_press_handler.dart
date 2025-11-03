import 'package:emulator_8085/models/trainer_state.dart';
import 'package:emulator_8085/src/cpu.dart';
import 'package:emulator_8085/src/memory.dart';

/// Handles all key press logic for the M85-03 trainer kit
class KeyPressHandler {
  final CPU cpu;
  final Memory memory;

  KeyPressHandler({
    required this.cpu,
    required this.memory,
  });

  /// Process a key press and return the updated trainer state
  TrainerState handleKeyPress(String key, TrainerState currentState) {
    // Handle RESET
    if (key == 'RESET') {
      return _handleReset();
    }

    // Handle SHIFT
    if (key == 'SHIFT') {
      return _handleShift(currentState);
    }

    // Handle EXREG (with SHIFT)
    if (currentState.shiftPressed && key == 'EXREG') {
      return _handleExregMode(currentState);
    }

    // Handle register selection in EXREG mode
    if (currentState.mode == OperatingMode.exreg && 'ABCDEHL'.contains(key)) {
      return _handleRegisterExamine(key, currentState);
    }

    // Handle EXMEM
    if (key == 'EXMEM') {
      return _handleExmemMode(currentState);
    }

    // Handle NEXT
    if (key == 'NEXT') {
      return _handleNext(currentState);
    }

    // Handle GO and . (FILL)
    if (key == 'GO' || key == '.') {
      return _handleGo(currentState);
    }

    // Handle hex digit input
    if ('0123456789ABCDEF'.contains(key)) {
      return _handleHexInput(key, currentState);
    }

    return currentState;
  }

  /// Reset the entire system
  TrainerState _handleReset() {
    cpu.reset();
    memory.reset();
    final state = TrainerState();
    state.statusMessage = 'System Reset';
    return state;
  }

  /// Toggle SHIFT state
  TrainerState _handleShift(TrainerState state) {
    return state.copyWith(
      shiftPressed: !state.shiftPressed,
      statusMessage: !state.shiftPressed ? 'Shift ON' : 'Shift OFF',
    );
  }

  /// Enter EXREG mode
  TrainerState _handleExregMode(TrainerState state) {
    return state.copyWith(
      mode: OperatingMode.exreg,
      addressDisplay: 'REG-',
      dataDisplay: '--',
      shiftPressed: false,
      statusMessage: 'Examine Register - Press A/B/C/D/E/H/L',
    );
  }

  /// Examine a specific register
  TrainerState _handleRegisterExamine(String regName, TrainerState state) {
    int regValue = 0;
    switch (regName) {
      case 'A': regValue = cpu.a; break;
      case 'B': regValue = cpu.b; break;
      case 'C': regValue = cpu.c; break;
      case 'D': regValue = cpu.d; break;
      case 'E': regValue = cpu.e; break;
      case 'H': regValue = cpu.h; break;
      case 'L': regValue = cpu.l; break;
    }

    final dataHex = regValue.toRadixString(16).toUpperCase().padLeft(2, '0');
    return state.copyWith(
      addressDisplay: 'R-$regName ',
      dataDisplay: dataHex,
      mode: OperatingMode.idle,
      statusMessage: 'Register $regName = ${dataHex}H',
    );
  }

  /// Enter EXMEM mode
  TrainerState _handleExmemMode(TrainerState state) {
    return state.copyWith(
      mode: OperatingMode.exmem,
      inputBuffer: '',
      addressDisplay: '----',
      dataDisplay: '--',
      statusMessage: 'Examine Memory - Enter 4-digit Address',
    );
  }

  /// Handle NEXT key press
  TrainerState _handleNext(TrainerState state) {
    // Case 1: User entered a 4-digit address
    if (state.inputBuffer.length == 4) {
      cpu.pc = int.parse(state.inputBuffer, radix: 16);
      final addressHex = state.inputBuffer.toUpperCase();

      if (state.mode == OperatingMode.exmem) {
        // In EXMEM mode, show existing data
        final data = memory[cpu.pc];
        final dataHex = data.toRadixString(16).toUpperCase().padLeft(2, '0');
        return state.copyWith(
          addressDisplay: addressHex,
          dataDisplay: dataHex,
          inputBuffer: '',
          statusMessage: 'Memory [$addressHex] = ${dataHex}H',
        );
      } else {
        // In data entry mode, prepare for data input
        return state.copyWith(
          addressDisplay: addressHex,
          dataDisplay: '--',
          inputBuffer: '',
          statusMessage: 'Enter 2-digit data for address $addressHex',
        );
      }
    }
    // Case 2: User entered 2 digits of data to store
    else if (state.inputBuffer.length == 2) {
      memory[cpu.pc] = int.parse(state.inputBuffer, radix: 16);
      final dataHex = state.inputBuffer.toUpperCase();
      final currentAddress = cpu.pc.toRadixString(16).toUpperCase().padLeft(4, '0');

      // Advance to next memory location
      cpu.pc = (cpu.pc + 1) & 0xFFFF;
      final nextAddress = cpu.pc.toRadixString(16).toUpperCase().padLeft(4, '0');
      final nextData = memory[cpu.pc];
      final nextDataHex = nextData.toRadixString(16).toUpperCase().padLeft(2, '0');

      return state.copyWith(
        addressDisplay: nextAddress,
        dataDisplay: nextDataHex,
        inputBuffer: '',
        statusMessage: 'Stored ${dataHex}H at ${currentAddress}H',
      );
    }
    // Case 3: No input, just navigate to next memory location
    else if (state.inputBuffer.isEmpty) {
      cpu.pc = (cpu.pc + 1) & 0xFFFF;
      final data = memory[cpu.pc];
      final addressHex = cpu.pc.toRadixString(16).toUpperCase().padLeft(4, '0');
      final dataHex = data.toRadixString(16).toUpperCase().padLeft(2, '0');

      return state.copyWith(
        addressDisplay: addressHex,
        dataDisplay: dataHex,
        statusMessage: 'Memory [$addressHex] = ${dataHex}H',
      );
    }

    return state;
  }

  /// Handle GO/FILL key press to execute program
  TrainerState _handleGo(TrainerState state) {
    if (state.inputBuffer.length == 4) {
      cpu.pc = int.parse(state.inputBuffer, radix: 16);

      // Execute program (synchronous for now)
      _runProgram();

      return state.copyWith(
        inputBuffer: '',
        statusMessage: cpu.halted
            ? 'Execution Halted at ${cpu.pc.toRadixString(16).toUpperCase()}H'
            : 'Execution completed',
      );
    } else {
      return state.copyWith(
        statusMessage: 'Enter 4-digit address first',
      );
    }
  }

  /// Handle hexadecimal digit input
  TrainerState _handleHexInput(String digit, TrainerState state) {
    // Entering a 4-digit address
    if (state.addressDisplay.contains('-') && state.inputBuffer.length < 4) {
      final newBuffer = state.inputBuffer + digit;
      return state.copyWith(
        inputBuffer: newBuffer,
        addressDisplay: newBuffer.toUpperCase().padRight(4, '-'),
        statusMessage: 'Entering address: ${newBuffer.toUpperCase()}',
      );
    }
    // Entering 2-digit data
    else if (state.dataDisplay.contains('-') && state.inputBuffer.length < 2) {
      final newBuffer = state.inputBuffer + digit;
      return state.copyWith(
        inputBuffer: newBuffer,
        dataDisplay: newBuffer.toUpperCase().padRight(2, '-'),
        statusMessage: 'Entering data: ${newBuffer.toUpperCase()}',
      );
    }

    return state;
  }

  /// Execute the program (simple synchronous execution)
  void _runProgram() {
    int count = 0;
    while (!cpu.halted && count < 100000) {
      cpu.step();
      count++;
    }
  }
}
