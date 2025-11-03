/// Operating modes of the M85-03 trainer kit
enum OperatingMode {
  idle,
  exmem,    // Examine Memory
  insdata,  // Insert Data (not used in current implementation)
  exreg,    // Examine Register
  running,  // Program execution
}

/// State management for the M85-03 trainer kit
class TrainerState {
  String addressDisplay;
  String dataDisplay;
  String inputBuffer;
  OperatingMode mode;
  bool shiftPressed;
  String statusMessage;

  TrainerState({
    this.addressDisplay = '----',
    this.dataDisplay = '--',
    this.inputBuffer = '',
    this.mode = OperatingMode.idle,
    this.shiftPressed = false,
    this.statusMessage = 'Ready - M85-03 Training Kit',
  });

  /// Reset the trainer state to initial values
  void reset() {
    addressDisplay = '----';
    dataDisplay = '--';
    inputBuffer = '';
    mode = OperatingMode.idle;
    shiftPressed = false;
    statusMessage = 'System Reset';
  }

  /// Copy the current state with optional modifications
  TrainerState copyWith({
    String? addressDisplay,
    String? dataDisplay,
    String? inputBuffer,
    OperatingMode? mode,
    bool? shiftPressed,
    String? statusMessage,
  }) {
    return TrainerState(
      addressDisplay: addressDisplay ?? this.addressDisplay,
      dataDisplay: dataDisplay ?? this.dataDisplay,
      inputBuffer: inputBuffer ?? this.inputBuffer,
      mode: mode ?? this.mode,
      shiftPressed: shiftPressed ?? this.shiftPressed,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
