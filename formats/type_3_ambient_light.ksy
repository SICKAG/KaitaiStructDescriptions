meta:
  id: type_3_ambient_light
  endian: le
  bit-endian: be

  imports:
    - compact_header

doc: |
  Compact Format Type 3 - Ambient Light.
  Sensor: multiScan200.

seq:
  - id: header
    type: compact_header
    doc: Common compact telegram header.

  - id: frame_number
    type: u8
    doc: |
      Number of the corresponding primary distance data frame. Distance and
      ambient-light data acquired at the same time have the same frame ID.

  - id: timestamp_start
    type: u8
    doc: Time of measurement of the first column [Unix time, us].

  - id: timestamp_stop
    type: u8
    doc: Time of measurement of the last column [Unix time, us].

  - id: number_of_layers
    type: u2
    doc: Number of layers.

  - id: number_of_columns
    type: u2
    doc: Number of columns (slots).

  - id: horizontal_angle_start
    type: f4
    doc: Theta angle of the pixel with index (0, 0).

  - id: horizontal_angle_stop
    type: f4
    doc: Theta angle of the pixel with index
      (NumberOfLayers-1, NumberOfSlots-1).

  - id: vertical_angle_start
    type: f4
    doc: Phi angle of the pixel with index (0, 0).

  - id: vertical_angle_stop
    type: f4
    doc: Phi angle of the pixel with index
      (NumberOfLayers-1, NumberOfSlots-1).

  - id: encoding
    type: u2
    doc: Encoding of the pixel values; 0 = raw uint16 values.

  - id: ambient_light_data
    type: u2
    repeat: expr
    repeat-expr: number_of_layers * number_of_columns
    doc: |
      Pixel values, length = NumberOfLayers * NumberOfSlots.
      Ordering is described by the ambient light compact format.
