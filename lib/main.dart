import 'package:emulator_8085/controllers/key_press_handler.dart';
import 'package:emulator_8085/models/trainer_state.dart';
import 'package:emulator_8085/src/cpu.dart';
import 'package:emulator_8085/src/memory.dart';
import 'package:emulator_8085/widgets/keyboard.dart';
import 'package:emulator_8085/widgets/register_display.dart';
import 'package:emulator_8085/widgets/seven_segment_display.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const Emulator8085App());
}

class Emulator8085App extends StatelessWidget {
  const Emulator8085App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M85-03 Microprocessor Training Kit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.orbitron().fontFamily,
      ),
      home: const Emulator8085(),
    );
  }
}

class Emulator8085 extends StatefulWidget {
  const Emulator8085({super.key});

  @override
  State<Emulator8085> createState() => _Emulator8085State();
}

class _Emulator8085State extends State<Emulator8085> {
  late final CPU cpu;
  late final Memory memory;
  late final KeyPressHandler keyPressHandler;
  late TrainerState trainerState;

  @override
  void initState() {
    super.initState();
    memory = Memory(65536); // 64K of memory
    cpu = CPU(memory);
    keyPressHandler = KeyPressHandler(cpu: cpu, memory: memory);
    trainerState = TrainerState();
  }

  void handleKeyPress(String key) {
    setState(() {
      trainerState = keyPressHandler.handleKeyPress(key, trainerState);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildTrainerKit(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.developer_board, size: 60, color: Color(0xFFF39C12)),
        const SizedBox(height: 12),
        const Text(
          'M85-03 TRAINER',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF39C12),
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '8085 Microprocessor Emulator',
          style: TextStyle(fontSize: 18, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildTrainerKit() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF333333), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF444444), width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSevenSegmentDisplay(),
          const SizedBox(height: 24),
          _buildStatusBar(),
          const SizedBox(height: 28),
          _buildKeyboard(),
          const SizedBox(height: 24),
          _buildRegisterDisplay(),
        ],
      ),
    );
  }

  Widget _buildSevenSegmentDisplay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 3,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...trainerState.addressDisplay.split('').map((digit) => SevenSegment(value: digit)).toList(),
          const SizedBox(width: 16),
          ...trainerState.dataDisplay.split('').map((digit) => SevenSegment(value: digit)).toList(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        '${trainerState.statusMessage}${trainerState.shiftPressed ? ' [SHIFT]' : ''}',
        style: const TextStyle(
          color: Color(0xFF39FF14),
          fontSize: 15,
          fontFamily: 'VT323',
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildKeyboard() {
    return TrainerKeyboard(onKeyPress: handleKeyPress);
  }

  Widget _buildRegisterDisplay() {
    final registerMap = {
      'A': cpu.a, 'B': cpu.b, 'C': cpu.c, 'D': cpu.d, 
      'E': cpu.e, 'H': cpu.h, 'L': cpu.l, 'SP': cpu.sp, 'PC': cpu.pc
    };

    return RegisterDisplay(registers: registerMap);
  }
}
