meta:
  id: compact_header
  endian: le

doc: |
  Compact header shared by telegram type 4.

seq:
  - id: telegram_counter
    type: u8
    doc: Counts telegrams since power-up, starts at 1.

  - id: transmit_timestamp
    type: u8
    doc: Unix timestamp [us] at transmit time.

  - id: telegram_version
    type: u4

  - id: payload_length
    type: u4
    doc: For type 4 telegram_version 1, sender_id is counted in payload_length. From version 2 onwards it is not.

  - id: sender_id
    type: u4
    doc: Device serial number.
