# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a 3D "Squash the Creeps" game built with **Godot 4.4** engine with **C# support**. It's a simple action game where the player controls a character that jumps on enemies (mobs) to defeat them while avoiding getting hit.

## Development Commands

### Building the Project
```powershell
# Build using dotnet (for C# components)
dotnet build "Squash the Creeps (3D).csproj"

# Or build using SCons (from .vscode/tasks.json)
scons dev_build=yes
```

### Running the Game
```powershell
# Run from Godot editor (replace with your Godot path)
"C:/Users/hero-/Desktop/Godot_v4.4.1-stable_mono_win64/Godot_v4.4.1-stable_mono_win64.exe" --path "D:\Games\3d_squash_the_creeps_starter"

# Run without editor
"C:/Users/hero-/Desktop/Godot_v4.4.1-stable_mono_win64/Godot_v4.4.1-stable_mono_win64.exe" --path "D:\Games\3d_squash_the_creeps_starter" --headless
```

### Debugging
The project includes VSCode configuration for debugging:
- Launch configuration available in `.vscode/launch.json`
- Build task configured in `.vscode/tasks.json`
- Use F5 in VSCode to start debugging

## Code Architecture

### Core Scene Structure
- **main.tscn**: Root scene containing the game arena, UI, and game logic
- **player.tscn**: Player character with collision detection and movement
- **mob.tscn**: Enemy characters that spawn and move toward the player
- **music_player.tscn**: Audio management (autoloaded)

### Script Architecture
The project uses a **hybrid GDScript/C# approach**:

#### GDScript Files (Primary Implementation)
- `main.gd`: Game orchestration, mob spawning, game state management
- `mob.gd`: Enemy AI, movement, and lifecycle
- `Player.gd`: Player movement, physics, collision handling
- `score_label.gd`: Score tracking and display

#### C# Implementation (Alternative)
- `Player.cs`: C# version of player controller (identical functionality to Player.gd)

### Key Systems

#### Physics and Collision Layers
- **Layer 1**: Player (collision_layer = 1)
- **Layer 2**: Enemies/Mobs (collision_layer = 2)  
- **Layer 3**: World/Ground (collision_layer = 4)

#### Signal System
- `Player.hit` → `Main._on_player_hit()`: Game over handling
- `Mob.squashed` → `ScoreLabel._on_mob_squashed()`: Score increment
- `MobTimer.timeout` → `Main._on_mob_timer_timeout()`: Mob spawning

#### Spawning System
- Mobs spawn along a `Path3D` with randomized positions
- `PathFollow3D` node provides spawn locations around the arena perimeter
- Random speed and slight direction variation for each mob

### Input Mapping
- **WASD/Arrow Keys**: Player movement (move_left, move_right, move_forward, move_back)
- **Space**: Jump
- **Enter**: Restart game after game over

## File Organization

### Scripts
- Root-level scripts for main game objects
- C# scripts follow .NET naming conventions with Pascal case
- GDScript follows snake_case conventions

### Assets
- `art/`: 3D models (GLB format) and audio files
  - `player.glb`: Player character model
  - `mob.glb`: Enemy character model  
  - `House In a Forest Loop.ogg`: Background music
- `fonts/`: Typography assets
- `.godot/`: Engine cache and imported assets (auto-generated)

### Configuration
- `project.godot`: Main project configuration with input maps and scene settings
- `Squash the Creeps (3D).csproj`: .NET 8.0 project file for C# compilation
- `.vscode/`: Editor configuration for debugging and building

## Development Notes

### Language Choice
The project demonstrates both GDScript and C# implementations for the Player class. Use GDScript (`Player.gd`) for consistency with the rest of the codebase, or C# (`Player.cs`) if extending C# functionality.

### Scene Instantiation Pattern
Mobs are instantiated dynamically via `PackedScene.instantiate()` and configured through the `initialize()` method pattern, which is common in Godot for configuring spawned objects.

### 3D Physics Considerations
- Uses `CharacterBody3D` for both player and mobs
- Ground collision uses `StaticBody3D` 
- Collision detection combines physics layers with signal-based area detection (`MobDetector`)
- Player bouncing uses velocity manipulation rather than physics impulses