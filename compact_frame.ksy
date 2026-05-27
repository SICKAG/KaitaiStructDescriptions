meta:
  id: compact_frame
  endian: le
  bit-endian: be

  imports:
    - type_1_primary_data
    - type_2_imu
    - type_4_encoder

seq:
  - id: magic
    contents: [0x02, 0x02, 0x02, 0x02]

  - id: command_id
    type: u4
    doc: |
      Type of the transmitted telegram.
        1 = Primary data (distance / RSSI)
        2 = IMU data
        4 = Encoder

  - id: payload
    type:
      switch-on: command_id
      cases:
        1: primary_data
        2: imu
        4: encoder

  - id: checksum
    type: u4
    doc: |
      CRC32 checksum calculated over the entire data package:
      magic + command_id + payload.
