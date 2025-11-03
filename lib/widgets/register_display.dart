import 'package:flutter/material.dart';

/// CPU Register Display Widget
/// Shows the current state of all CPU registers
class RegisterDisplay extends StatelessWidget {
  final Map<String, int> registers;

  const RegisterDisplay({
    super.key,
    required this.registers,
  });

  @override
  Widget build(BuildContext context) {
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
              crossAxisCount: 5,
              childAspectRatio: 1.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: registers.length,
            itemBuilder: (context, index) {
              final key = registers.keys.elementAt(index);
              final value = registers[key]!;
              return RegisterCell(
                name: key,
                value: value,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Individual register cell displaying a register name and value
class RegisterCell extends StatelessWidget {
  final String name;
  final int value;

  const RegisterCell({
    super.key,
    required this.name,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = name == 'PC' || name == 'SP';

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
            name,
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
  }
}
