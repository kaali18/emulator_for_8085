class Memory {
  final List<int> _data;

  Memory(int size) : _data = List<int>.filled(size, 0);

  int operator [](int address) {
    if (address < 0 || address >= _data.length) {
      // throw RangeError('Address out of bounds: $address');
      return 0; // Return 0 for out-of-bounds access, common in simple emulators
    }
    return _data[address];
  }

  void operator []=(int address, int value) {
    if (address >= 0 && address < _data.length) {
      _data[address] = value & 0xFF; // Ensure only 8-bit values are stored
    }
  }

  void reset() {
    for (int i = 0; i < _data.length; i++) {
      _data[i] = 0;
    }
  }

  int get length => _data.length;
}
