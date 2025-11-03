import 'package:emulator_8085/src/cpu.dart';
import 'package:emulator_8085/src/memory.dart';
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

  String addressDisplay = '----';
  String dataDisplay = '--';
  String inputBuffer = '';
  String mode = 'IDLE';
  bool shiftPressed = false;
  String statusMessage = 'Ready - M85-03 Training Kit';

  @override
  void initState() {
    super.initState();
    memory = Memory(65536); // 64K of memory
    cpu = CPU(memory);
  }

  void handleKeyPress(String key) {
    setState(() {
      if (key == 'RESET') {
        cpu.reset();
        memory.reset();
        inputBuffer = '';
        addressDisplay = '----';
        dataDisplay = '--';
        mode = 'IDLE';
        shiftPressed = false;
        statusMessage = 'System Reset';
        return;
      }

      if (key == 'SHIFT') {
        shiftPressed = !shiftPressed;
        statusMessage = shiftPressed ? 'Shift ON' : 'Shift OFF';
        return;
      }

      if (shiftPressed && key == 'EXREG') {
        mode = 'EXREG';
        statusMessage = 'Examine Register - Press A/B/C/D/E/H/L';
        addressDisplay = 'REG-';
        dataDisplay = '--';
        shiftPressed = false;
        return;
      }

      if (mode == 'EXREG' && 'ABCDEHL'.contains(key)) {
        int regValue = 0;
        switch (key) {
          case 'A': regValue = cpu.a; break;
          case 'B': regValue = cpu.b; break;
          case 'C': regValue = cpu.c; break;
          case 'D': regValue = cpu.d; break;
          case 'E': regValue = cpu.e; break;
          case 'H': regValue = cpu.h; break;
          case 'L': regValue = cpu.l; break;
        }
        addressDisplay = 'R-$key ';
        dataDisplay = regValue.toRadixString(16).toUpperCase().padLeft(2, '0');
        statusMessage = 'Register $key = ${dataDisplay}H';
        mode = 'IDLE';
        return;
      }

      if (key == 'EXMEM') {
        mode = 'EXMEM';
        inputBuffer = '';
        addressDisplay = '----';
        dataDisplay = '--';
        statusMessage = 'Examine Memory - Enter 4-digit Address';
        return;
      }

      if (key == 'NEXT') {
        // Case 1: User entered a 4-digit address to start examining/writing.
        if (inputBuffer.length == 4) {
          cpu.pc = int.parse(inputBuffer, radix: 16);
          addressDisplay = inputBuffer.toUpperCase();
          // Check if we are in EXMEM mode to show existing data, otherwise prepare for input.
          if (mode == 'EXMEM') {
            final data = memory[cpu.pc];
            dataDisplay = data.toRadixString(16).toUpperCase().padLeft(2, '0');
            statusMessage = 'Memory [$addressDisplay] = ${dataDisplay}H';
          } else {
            dataDisplay = '--';
            statusMessage = 'Enter 2-digit data for address $addressDisplay';
          }
          inputBuffer = '';
        } 
        // Case 2: User entered 2 digits of data to be stored.
        else if (inputBuffer.length == 2) {
          memory[cpu.pc] = int.parse(inputBuffer, radix: 16);
          dataDisplay = inputBuffer.toUpperCase();
          statusMessage = 'Stored ${dataDisplay}H at ${addressDisplay}H';
          
          // Automatically advance to the next memory location.
          cpu.pc = (cpu.pc + 1) & 0xFFFF;
          addressDisplay = cpu.pc.toRadixString(16).toUpperCase().padLeft(4, '0');
          final nextData = memory[cpu.pc];
          dataDisplay = nextData.toRadixString(16).toUpperCase().padLeft(2, '0');
          inputBuffer = '';
        }
        // Case 3: No input, just move to the next memory location (like in EXMEM).
        else if (inputBuffer.isEmpty) {
          cpu.pc = (cpu.pc + 1) & 0xFFFF;
          final data = memory[cpu.pc];
          addressDisplay = cpu.pc.toRadixString(16).toUpperCase().padLeft(4, '0');
          dataDisplay = data.toRadixString(16).toUpperCase().padLeft(2, '0');
          statusMessage = 'Memory [$addressDisplay] = ${dataDisplay}H';
        }
        return;
      }

      if (key == 'GO' || key == '.') {
        if (inputBuffer.length == 4) {
          cpu.pc = int.parse(inputBuffer, radix: 16);
          statusMessage = 'Executing from ${inputBuffer.toUpperCase()}H';
          inputBuffer = '';
          _runProgram();
        } else {
          statusMessage = 'Enter 4-digit address first';
        }
        return;
      }

      if ('0123456789ABCDEF'.contains(key)) {
        // Entering a 4-digit address
        if (addressDisplay.contains('-') && inputBuffer.length < 4) {
          inputBuffer += key;
          addressDisplay = inputBuffer.toUpperCase().padRight(4, '-');
          statusMessage = 'Entering address: ${inputBuffer.toUpperCase()}';
        } 
        // Entering 2-digit data
        else if (dataDisplay.contains('-') && inputBuffer.length < 2) {
          inputBuffer += key;
          dataDisplay = inputBuffer.toUpperCase().padRight(2, '-');
          statusMessage = 'Entering data: ${inputBuffer.toUpperCase()}';
        }
        return;
      }
    });
  }

  void _runProgram() {
    // Simple synchronous execution loop for now.
    // A more advanced implementation would use an Isolate.
    int count = 0;
    while (!cpu.halted && count < 100000) { // Safety break
      cpu.step();
      count++;
    }
    if (cpu.halted) {
      statusMessage = 'Execution Halted at ${cpu.pc.toRadixString(16).toUpperCase()}H';
    } else {
      statusMessage = 'Execution timed out.';
    }
    // Update UI after execution
    setState(() {});
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
          ...addressDisplay.split('').map((digit) => SevenSegment(value: digit)).toList(),
          const SizedBox(width: 16),
          ...dataDisplay.split('').map((digit) => SevenSegment(value: digit)).toList(),
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
        '$statusMessage${shiftPressed ? ' [SHIFT]' : ''}',
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
    final keys = [
      '7', '8', '9', 'EXMEM',
      '4', '5', '6', 'NEXT',
      '1', '2', '3', 'GO',
      '0', 'A', 'B', '.',
      'C', 'D', 'E', 'SHIFT',
      'F', 'H', 'L', 'RESET',
      'EXREG'
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: keys.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final key = keys[index];
        bool isFunction = 'EXMEM,NEXT,GO,.,SHIFT,RESET,EXREG'.contains(key);
        bool isHex = '0123456789ABCDEF'.contains(key);
        bool isRegister = 'HL'.contains(key);

        return _buildKeyButton(key, isHex: isHex, isFunction: isFunction, isRegister: isRegister);
      },
    );
  }

  Widget _buildKeyButton(String label, {bool isHex = false, bool isFunction = false, bool isRegister = false}) {
    Color startColor, endColor, textColor;
    
    if (isFunction || label == '.') {
      startColor = const Color(0xFFD32F2F);
      endColor = const Color(0xFFB71C1C);
      textColor = Colors.white;
    } else if (isRegister) {
      startColor = const Color(0xFF388E3C);
      endColor = const Color(0xFF1B5E20);
      textColor = Colors.white;
    } else { // Hex keys
      startColor = const Color(0xFF455A64);
      endColor = const Color(0xFF263238);
      textColor = const Color(0xFFECEFF1);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 5,
            offset: const Offset(2, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => handleKeyPress(label),
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: label.length > 4 ? 12 : 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterDisplay() {
    final registerMap = {
      'A': cpu.a, 'B': cpu.b, 'C': cpu.c, 'D': cpu.d, 
      'E': cpu.e, 'H': cpu.h, 'L': cpu.l, 'SP': cpu.sp, 'PC': cpu.pc
    };

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CPU REGISTERS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF39C12),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // Changed from 4 to 5
              childAspectRatio: 1.8, // Adjusted aspect ratio
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: registerMap.length,
            itemBuilder: (context, index) {
              final key = registerMap.keys.elementAt(index);
              final value = registerMap[key]!;
              final isWide = key == 'PC' || key == 'SP';
              
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      key,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value.toRadixString(16).toUpperCase().padLeft(isWide ? 4 : 2, '0'),
                      style: const TextStyle(
                        color: Color(0xFF39FF14),
                        fontSize: 14,
                        fontFamily: 'VT323',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SevenSegment extends StatelessWidget {
  final String value;

  const SevenSegment({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final segments = _getSegments(value.toUpperCase());

    return Container(
      width: 32, // Reduced width
      height: 60, // Reduced height
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: CustomPaint(
        painter: SevenSegmentPainter(segments),
      ),
    );
  }

  List<bool> _getSegments(String char) {
    const Map<String, List<bool>> segmentMap = {
      '0': [true, true, true, true, true, true, false],
      '1': [false, true, true, false, false, false, false],
      '2': [true, true, false, true, true, false, true],
      '3': [true, true, true, true, false, false, true],
      '4': [false, true, true, false, false, true, true],
      '5': [true, false, true, true, false, true, true],
      '6': [true, false, true, true, true, true, true],
      '7': [true, true, true, false, false, false, false],
      '8': [true, true, true, true, true, true, true],
      '9': [true, true, true, true, false, true, true],
      'A': [true, true, true, false, true, true, true],
      'B': [false, false, true, true, true, true, true],
      'C': [true, false, false, true, true, true, false],
      'D': [false, true, true, true, true, false, true],
      'E': [true, false, false, true, true, true, true],
      'F': [true, false, false, false, true, true, true],
      '-': [false, false, false, false, false, false, true],
      'R': [true, false, false, false, true, false, true], // Custom for 'R'
      'G': [true, false, true, true, true, true, false], // Custom for 'G'
      ' ': [false, false, false, false, false, false, false],
    };

    return segmentMap[char] ?? [false, false, false, false, false, false, false];
  }
}

class SevenSegmentPainter extends CustomPainter {
  final List<bool> segments;

  SevenSegmentPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final onPaint = Paint()
      ..color = const Color(0xFFFF1744)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.5);

    final offPaint = Paint()
      ..color = const Color(0xFF4A0404).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final thickness = 6.0; // Reduced thickness

    // Segment paths
    final paths = [
      // A (top)
      _getHorizontalPath(w * 0.1, 0, w * 0.8, thickness),
      // B (top-right)
      _getVerticalPath(w - thickness, h * 0.05, h * 0.4, thickness),
      // C (bottom-right)
      _getVerticalPath(w - thickness, h * 0.55, h * 0.4, thickness),
      // D (bottom)
      _getHorizontalPath(w * 0.1, h - thickness, w * 0.8, thickness),
      // E (bottom-left)
      _getVerticalPath(0, h * 0.55, h * 0.4, thickness),
      // F (top-left)
      _getVerticalPath(0, h * 0.05, h * 0.4, thickness),
      // G (middle)
      _getHorizontalPath(w * 0.1, h / 2 - thickness / 2, w * 0.8, thickness),
    ];

    for (int i = 0; i < 7; i++) {
      canvas.drawPath(paths[i], segments[i] ? onPaint : offPaint);
    }
  }

  Path _getHorizontalPath(double x, double y, double width, double thickness) {
    return Path()
      ..moveTo(x + thickness * 0.5, y)
      ..lineTo(x + width - thickness * 0.5, y)
      ..lineTo(x + width, y + thickness / 2)
      ..lineTo(x + width - thickness * 0.5, y + thickness)
      ..lineTo(x + thickness * 0.5, y + thickness)
      ..lineTo(x, y + thickness / 2)
      ..close();
  }

  Path _getVerticalPath(double x, double y, double height, double thickness) {
    return Path()
      ..moveTo(x + thickness / 2, y)
      ..lineTo(x + thickness, y + thickness * 0.5)
      ..lineTo(x + thickness, y + height - thickness * 0.5)
      ..lineTo(x + thickness / 2, y + height)
      ..lineTo(x, y + height - thickness * 0.5)
      ..lineTo(x, y + thickness * 0.5)
      ..close();
  }

  @override
  bool shouldRepaint(SevenSegmentPainter oldDelegate) => true;
}
