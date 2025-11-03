import 'package:flutter/material.dart';

/// M85-03 Keyboard Widget
/// Represents the 28-key hexadecimal keyboard of the trainer kit
class TrainerKeyboard extends StatelessWidget {
  final Function(String) onKeyPress;

  const TrainerKeyboard({
    super.key,
    required this.onKeyPress,
  });

  @override
  Widget build(BuildContext context) {
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
        final keyType = _getKeyType(key);
        return KeyButton(
          label: key,
          type: keyType,
          onPressed: () => onKeyPress(key),
        );
      },
    );
  }

  KeyType _getKeyType(String key) {
    if ('0123456789ABCDEF'.contains(key)) {
      return KeyType.hex;
    } else if ('HL'.contains(key)) {
      return KeyType.register;
    } else {
      return KeyType.function;
    }
  }
}

/// Types of keys on the keyboard
enum KeyType {
  hex,
  function,
  register,
}

/// Individual key button widget
class KeyButton extends StatelessWidget {
  final String label;
  final KeyType type;
  final VoidCallback onPressed;

  const KeyButton({
    super.key,
    required this.label,
    required this.type,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.startColor, colors.endColor],
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
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: colors.textColor,
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

  _KeyColors _getColors() {
    switch (type) {
      case KeyType.function:
        return _KeyColors(
          startColor: const Color(0xFFD32F2F),
          endColor: const Color(0xFFB71C1C),
          textColor: Colors.white,
        );
      case KeyType.register:
        return _KeyColors(
          startColor: const Color(0xFF388E3C),
          endColor: const Color(0xFF1B5E20),
          textColor: Colors.white,
        );
      case KeyType.hex:
        return _KeyColors(
          startColor: const Color(0xFF455A64),
          endColor: const Color(0xFF263238),
          textColor: const Color(0xFFECEFF1),
        );
    }
  }
}

/// Color scheme for different key types
class _KeyColors {
  final Color startColor;
  final Color endColor;
  final Color textColor;

  _KeyColors({
    required this.startColor,
    required this.endColor,
    required this.textColor,
  });
}
