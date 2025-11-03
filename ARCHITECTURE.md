# M85-03 8085 Microprocessor Training Kit Emulator

A Flutter-based emulator for the M85-03 microprocessor training kit, featuring a complete 8085 CPU simulation with an authentic vintage hardware interface.

## 📁 Project Structure

The codebase is organized into a modular architecture for better maintainability and understanding:

```
lib/
├── main.dart                          # Main app entry point and UI composition
├── models/                            # Data models
│   └── trainer_state.dart            # Trainer kit state management
├── controllers/                       # Business logic
│   └── key_press_handler.dart        # Keyboard input processing
├── widgets/                           # Reusable UI components
│   ├── seven_segment_display.dart    # 7-segment LED display widget
│   ├── keyboard.dart                 # 28-key hexadecimal keyboard
│   └── register_display.dart         # CPU register display panel
└── src/                               # Core emulator logic
    ├── cpu.dart                       # 8085 CPU implementation
    └── memory.dart                    # Memory management (64KB)
```

## 🧩 Module Descriptions

### 1. **Models** (`lib/models/`)

#### `trainer_state.dart`
- **Purpose**: Manages the state of the M85-03 trainer kit
- **Key Features**:
  - Address and data display states
  - Operating modes (IDLE, EXMEM, EXREG, etc.)
  - Input buffer management
  - Shift key state tracking
  - Status message handling

### 2. **Controllers** (`lib/controllers/`)

#### `key_press_handler.dart`
- **Purpose**: Handles all keyboard interactions and business logic
- **Key Features**:
  - Processes all 28 keyboard keys
  - Implements M85-03 operational procedures
  - Manages state transitions
  - Handles memory examination and data insertion
  - Executes programs

### 3. **Widgets** (`lib/widgets/`)

#### `seven_segment_display.dart`
- **Purpose**: Renders the 6-digit 7-segment LED display
- **Components**:
  - `SevenSegment`: Individual digit display widget
  - `SevenSegmentPainter`: Custom painter for LED segments
- **Features**: Supports 0-9, A-F, and special characters

#### `keyboard.dart`
- **Purpose**: Renders the 28-key hexadecimal keyboard
- **Components**:
  - `TrainerKeyboard`: Main keyboard grid layout
  - `KeyButton`: Individual key with styling
  - `KeyType`: Enum for key categorization (hex, function, register)
- **Features**: Color-coded keys with metallic styling

#### `register_display.dart`
- **Purpose**: Displays all CPU registers in real-time
- **Components**:
  - `RegisterDisplay`: Register grid container
  - `RegisterCell`: Individual register display
- **Features**: Shows A, B, C, D, E, H, L, SP, PC registers in hexadecimal

### 4. **Core** (`lib/src/`)

#### `cpu.dart`
- **Purpose**: Complete 8085 microprocessor simulation
- **Key Features**:
  - All 8 general-purpose registers (A, B, C, D, E, H, L)
  - 16-bit Stack Pointer (SP) and Program Counter (PC)
  - Flag register (Zero, Sign, Parity, Carry, Auxiliary Carry)
  - Full instruction set implementation
  - Instruction execution cycle
  - Halt state management

#### `memory.dart`
- **Purpose**: 64KB memory management
- **Key Features**:
  - Read/write operations
  - Memory reset functionality
  - Address range: 0x0000 - 0xFFFF

## 🎮 Operating Procedures

### Examine Memory (EXMEM)
```
RESET → EXMEM → 2500 → NEXT
```
Displays the contents of memory location 2500H. Press NEXT to view subsequent addresses.

### Insert Data (Program Entry)
```
RESET → EXMEM → 2000 → NEXT → 3E → NEXT → 05 → NEXT → 76 → NEXT
```
Enters the program:
- 2000H: 3E (MVI A, 05H)
- 2001H: 05
- 2002H: 76 (HLT)

### Execute Program
```
RESET → 2000 → . (FILL key)
```
Executes the program starting from address 2000H.

### Examine Registers
```
SHIFT → EXREG → A (or B/C/D/E/H/L)
```
Displays the contents of the selected register.

## 🏗️ Architecture Benefits

1. **Separation of Concerns**: Each module has a single, well-defined responsibility
2. **Maintainability**: Easy to locate and fix bugs in specific components
3. **Reusability**: Widgets can be reused in different contexts
4. **Testability**: Individual modules can be tested in isolation
5. **Scalability**: Easy to add new features or modify existing ones
6. **Readability**: Clear file structure makes navigation intuitive

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd emulator_8085

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## 🎨 UI Features

- **Dark metallic theme** for authentic hardware feel
- **Color-coded keyboard**:
  - Red: Function keys (RESET, EXMEM, NEXT, etc.)
  - Green: Register keys (H, L)
  - Gray: Hexadecimal keys (0-9, A-F)
- **Glowing LED display** with realistic 7-segment rendering
- **Real-time register updates** during program execution
- **Status bar** showing current operation and mode

## 📖 Documentation

Each file includes detailed inline documentation:
- Class-level comments explaining purpose
- Method-level comments describing functionality
- Complex logic is explained with inline comments

## 🔧 Development

### Adding New Instructions
1. Define the opcode in `cpu.dart`
2. Implement the instruction logic in the `executeInstruction()` method
3. Update the instruction cycle count if needed

### Modifying UI
1. Widget-specific changes: Edit the corresponding file in `lib/widgets/`
2. Layout changes: Modify `main.dart`
3. Styling constants can be extracted to a separate theme file if needed

## 📝 License

[Add your license information here]

## 👥 Contributors

[Add contributor information here]

## 🐛 Bug Reports

Please report issues on the GitHub issue tracker with:
- Description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
