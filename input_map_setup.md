# Input Map Setup for Fly Controller

To use the FlyController, you need to set up the following input actions in your Input Map:

## Required Input Actions:

1. **move_forward** - W key
2. **move_backward** - S key
3. **move_left** - A key
4. **move_right** - D key
5. **move_up** - Space key
6. **move_down** - Shift key
7. **roll_left** - Q key
8. **roll_right** - E key
9. **land** - L key (or any key you prefer)
10. **boost** - Left Shift key (or any key you prefer)

## Setup Instructions:

1. Go to Project → Project Settings → Input Map
2. Add each action listed above
3. Assign the corresponding keys
4. Save the project

## Controls Summary:

- **WASD**: Move forward/backward/left/right
- **Space/Shift**: Move up/down
- **Q/E**: Roll left/right
- **Mouse**: Look around (pitch/yaw)
- **L**: Toggle landing mode
- **Ctrl**: Boost (consumes stamina)
- **F**: Toggle fly vision filter (hexagonal compound eye effect)

## Features:

- 6-DOF flight with realistic drag and inertia
- Landing mode that aligns to surface normals
- Stamina system for boost mechanics
- Subtle head-bob effect when flying
- Surface-aligned movement when landed
