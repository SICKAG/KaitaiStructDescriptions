meta:
  id: imu
  endian: le
  bit-endian: be

seq:
  - id: telegram_version
    type: u4
    doc: Version of the telegram with the command_id used.
    valid: 1

  - id: acceleration
    type: vector3f
    doc: Acceleration in m/s^2

  - id: angular_velocity
    type: vector3f
    doc: Angular velocity in rad/s

  - id: orientation
    type: quaternion
    doc: |
      With the quaternion given as (w,x,y,z) the sensor orientation is obtained as:
      roll = atan(2 * (w * x + y * z), 1 - 2 * (x * x + y * y))
      pitch = asin(2 * (w * y - z * x))
      yaw = tan(2 * (w * z + x * y), 1 - 2 * (y * y + z * z))

  - id: timestamp
    doc: Sensor system time in µs since 1.1.1970 00:00 in UTC.
    type: u8

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
