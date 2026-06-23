meta:
  id: type_4_encoder
  endian: le
  bit-endian: be

  imports:
    - compact_header

doc: |
  Compact Format Type 4 - Encoder.
  Sensor: picoScan150.

seq:
  - id: header
    type: compact_header

  - id: frame_number
    type: u8
    doc: Corresponding primary data frame number.

  - id: tick_count
    type: u4

  - id: tick_count_at_reference_signal_1
    type: u4
    doc: Tick count when reference signal 1 signal detected.

  - id: tick_count_at_reference_signal_2
    type: u4
    doc: Tick count when reference signal 2 signal detected.

  - id: speed
    type: f4
    doc: Speed [units/s] per configured conversion rate.

  - id: tick_count_timestamp
    type: u8
    doc: Timestamp of last tick counter change [us, Unix].

  - id: timestamp_of_reference_signal_1
    type: u8
    doc: Timestamp of last reference signal 1 signal change [us, Unix].

  - id: timestamp_of_reference_signal_2
    type: u8
    doc: Timestamp of last reference signal 2 signal change [us, Unix].
