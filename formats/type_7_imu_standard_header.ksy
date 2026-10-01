meta:
  id: type_7_imu_standard_header
  endian: le
  bit-endian: be

  imports:
    - compact_header

doc: |
  Compact Format Type 7 - IMU (Standard Header).
  Unlike the Type 2 IMU telegram, this telegram is prefixed with the standard
  compact header.
  Sensors: multiScan200.

seq:
  - id: header
    type: compact_header
    doc: |
      Standard compact header (telegram types 3-7). Its presence is the key
      difference from the Type 2 IMU telegram, which has no standard compact header.

  - id: timestamp
    type: u8
    doc: Unix timestamp [us].

  - id: acceleration
    type: vector3f
    doc: Acceleration including gravity [m/s^2].

  - id: angular_velocity
    type: vector3f
    doc: Angular velocity [rad/s].

  - id: orientation
    type: quaternion
    doc: |
      With the quaternion given as (w,x,y,z) the sensor orientation is obtained as:
      roll = atan(2 * (w * x + y * z), 1 - 2 * (x * x + y * y))
      pitch = asin(2 * (w * y - z * x))
      yaw = tan(2 * (w * z + x * y), 1 - 2 * (y * y + z * z))

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
