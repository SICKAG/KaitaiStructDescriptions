meta:
  id: type_2_imu
  endian: le
  bit-endian: be

doc: |
  Compact Format Type 2.
  This telegram has no standard compact header.
  Sensors: picoScan100, multiScan100.

seq:
  - id: telegram_version
    type: u4
    valid: 1

  - id: acceleration
    type: vector3f
    doc: Acceleration in m/s^2.

  - id: angular_velocity
    type: vector3f
    doc: Angular velocity in rad/s.

  - id: orientation
    type: quaternion
    doc: |
      With the quaternion given as (w,x,y,z) the sensor orientation is obtained as:
      roll = atan(2 * (w * x + y * z), 1 - 2 * (x * x + y * y))
      pitch = asin(2 * (w * y - z * x))
      yaw = tan(2 * (w * z + x * y), 1 - 2 * (y * y + z * z))

  - id: timestamp
    type: u8
    doc: Unix timestamp [us].

types:
  vector3f:
    seq:
      - id: x
        type: f4

      - id: y
        type: f4

      - id: z
        type: f4

  quaternion:
    seq:
      - id: w
        type: f4

      - id: x
        type: f4

      - id: y
        type: f4

      - id: z
        type: f4
