meta:
  id: compact_frame
  endian: le
  bit-endian: be

  imports:
    - type_1_primary_data_spherical_coordinates
    - type_2_imu
    - type_4_encoder

seq:
  - id: start_of_frame
    contents: [0x02, 0x02, 0x02, 0x02]

  - id: telegram_type
    type: u4
    doc: |
      1 = Primary Data - Spherical Coordinates
      2 = IMU
      4 = Encoder

  - id: payload
    type:
      switch-on: telegram_type
      cases:
        1: type_1_primary_data_spherical_coordinates
        2: type_2_imu
        4: type_4_encoder

  - id: checksum
    type: u4
    doc: CRC32 over start_of_frame + telegram_type + payload.
