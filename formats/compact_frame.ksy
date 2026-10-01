meta:
  id: compact_frame
  endian: le
  bit-endian: be

  imports:
    - type_1_primary_data_spherical_coordinates
    - type_2_imu
    - type_3_ambient_light
    - type_4_encoder
    - type_6_primary_data_multiscan200
    - type_7_imu_standard_header

seq:
  - id: start_of_frame
    contents: [0x02, 0x02, 0x02, 0x02]

  - id: telegram_type
    type: u4
    doc: |
      1 = Primary Data - Spherical Coordinates
      2 = IMU
      3 = Ambient Light
      4 = Encoder
      6 = Primary Data - multiScan200
      7 = IMU (Standard Header)

  - id: payload
    type:
      switch-on: telegram_type
      cases:
        1: type_1_primary_data_spherical_coordinates
        2: type_2_imu
        3: type_3_ambient_light
        4: type_4_encoder
        6: type_6_primary_data_multiscan200
        7: type_7_imu_standard_header

  - id: checksum
    type: u4
    doc: CRC32 over start_of_frame + telegram_type + payload.
