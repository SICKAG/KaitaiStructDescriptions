meta:
  id: encoder
  endian: le
  bit-endian: be

seq:
  - id: telegram_counter
    type: u8
    doc: |
      Counts all telegrams sent since the device was switched on.
      The counter starts at 1.

  - id: timestamp_transmit
    type: u8
    doc: Sensor system time in µs since 1.1.1970 00:00 in UTC.

  - id: telegram_version
    type: u4
    doc: Version of the telegram with the command_id used.
    valid: 1

  - id: payload_length
    type: u4
    doc: Payload length without trailer (CRC32).

  - id: sender_id
    type: u4
    doc: |
      Serial number of the sensor sending the data.
      To be used to identify the origin of the data packet.

  - id: frame_number
    type: u8
    doc: Number of the corresponding primary data frame.

  - id: tick_count
    type: u4
    doc: Current tick count of the encoder.

  - id: tick_count_at_reference_signal_1
    type: u4
    doc: Tick count when reference signal 1 was detected.

  - id: tick_count_at_reference_signal_2
    type: u4
    doc: Tick count when reference signal 2 was detected.

  - id: speed
    type: f4
    doc: Speed in meters per second.

  - id: tick_count_timestamp
    type: u8
    doc: |
      Time when the tick counter last changed.
      Based on sensor system time since 1.1.1970 00:00 in UTC
      or system time (NTP/PTP) in microseconds.

  - id: timestamp_of_reference_signal_1
    type: u8
    doc: |
      Time when the reference signal 1 last changed.
      Based on sensor system time since 1.1.1970 00:00 in UTC
      or system time (NTP/PTP) in microseconds.

  - id: timestamp_of_reference_signal_2
    type: u8
    doc: |
      Time when the reference signal 2 last changed.
      Based on sensor system time since 1.1.1970 00:00 in UTC
      or system time (NTP/PTP) in microseconds.
