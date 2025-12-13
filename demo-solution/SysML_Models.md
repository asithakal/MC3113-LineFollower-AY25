# SysML Models - Line-Follower Demo Project

**Note:** These are textual descriptions. Use Gaphor or PowerPoint to create diagrams.

---

## Block Definition Diagram (BDD) - Top Level

```
«block»
LineFollowerSystem
  parts:
    - plant : Plant
    - controller : Controller
    - hmi : HMI
    - environment : Environment
  
«block»
Plant
  parts:
    - sensors : ReflectanceSensorArray
    - motors : DifferentialDrive
    - chassis : MobileBase
  values:
    - wheelbase : Real = 0.15 m
    - wheel_radius : Real = 0.03 m
    
«block»
Controller
  operations:
    - compute_control(inputs: SensorData) : Commands
  values:
    - Kp : Real = 1.2
    - Ki : Real = 0.3
    - base_speed : Real = 0.4

«block»
HMI
  operations:
    - start_scenario(id: ScenarioID)
    - log_telemetry(data: TelemetryPacket)

«block»
Environment
  parts:
    - track : LineTrack
    - obstacles : Obstacle [0..*]
```

---

## Internal Block Diagram (IBD) - System Connections

```
ibd [block] LineFollowerSystem [Main Connections]

Connections:
1. sensors:ReflectanceSensorArray → controller:Controller
   - sensor : float [0..1]
   - e_line : float [m]

2. environment:Environment → controller:Controller
   - obstacle_flag : bool
   - fault_flag : bool

3. plant:Plant → controller:Controller
   - v : float [m/s]
   - omega : float [rad/s]

4. controller:Controller → motors:DifferentialDrive
   - u_L : float [-1..1]
   - u_R : float [-1..1]

5. plant:Plant → hmi:HMI
   - x, y, theta : float
   - line_loss_flag : bool
   - safety_violation : bool
```

**Key Point:** Every flow must match an ICD signal with correct units and rate.

---

_End of SysML Models_
