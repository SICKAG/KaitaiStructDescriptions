meta:
  id: type_6_primary_data_multiscan200
  endian: le
  bit-endian: be

  imports:
    - compact_header

doc: |
  Compact Format Type 6 - Primary Data
  Sensor: multiScan200.

seq:
  - id: header
    type: compact_header
    doc: Common compact telegram header.

  - id: frame_number
    type: u8
    doc: Number of the current frame.

  - id: frame_time_stamp
    type: u8
    doc: Acquisition time of the first slot in the current frame [us, Unix UTC].

  - id: segment_index
    type: u2
    doc: |
      Zero-based index incremented for each point cloud segment belonging to a
      frame; reset to zero at frame start.

  - id: number_of_segments_per_frame
    type: u2
    doc: |
      Number of segments into which the complete measurement frame is split
      along the columns; 0 = no splitting.

  - id: number_of_columns_in_segment
    type: u2
    doc: Number of columns serialized in the current segment.

  - id: number_of_columns_per_frame
    type: u2
    doc: Total number of columns in this frame.

  - id: number_of_layers
    type: u2
    doc: Total number of layers in this frame.

  - id: number_of_echos
    type: u1
    doc: Number of echoes per pixel.

  - id: number_of_ambient_light_layer
    type: u2
    doc: Number of ambient-light measurement layers; 0 = no ambient data.

  - id: number_of_interlace_steps
    type: u1
    doc: Number of configured interlace steps.

  - id: current_interlace_index
    type: u1
    doc: Interlace index of the current frame.

  - id: scan_configuration_identifier
    type: u1
    doc: Identifier of the currently used scan configuration.

  - id: distance_scaling_factor
    type: f4
    doc: |
      Factor used to scale distance values in the beam data, allowing values
      above 65535 mm or sub-millimeter resolution. distance_mm_extern = distance_scaling_factor * distance.

  - id: data_content_echo
    type: u1
    doc: |
      Bitmask describing the information contained in the echo section:
      bit 0 = hasIntensity, bit 1 = hasPulseWidth, bit 2 = hasProperties.

  - id: reserved_payload
    size: 91
    doc: |
      Reserved padding.

  - id: ambient_light_data
    type: u2
    repeat: expr
    repeat-expr: number_of_ambient_light_layer * number_of_columns_in_segment
    doc: |
      Ambient image data from the passive bandpass image; multiplicity is
      number_of_ambient_light_layer * number_of_columns_in_segment.

  - id: elevation_angles
    type: f4
    repeat: expr
    repeat-expr: number_of_layers
    doc: Vector of elevation-angle data [rad] for the serialized layers.

  - id: azimuth_angles
    type: f4
    repeat: expr
    repeat-expr: number_of_columns_in_segment
    doc: Vector of azimuth-angle data [rad] for the serialized columns.

  - id: relative_time_stamps
    type: u4
    repeat: expr
    repeat-expr: number_of_columns_in_segment
    doc: Column-relative time since frame_time_stamp [us].

  - id: column_properties
    type: u2
    repeat: expr
    repeat-expr: number_of_columns_in_segment
    doc: Per-column status flags, including missed-column and pollution detection flags.

  - id: distance
    type: u2
    repeat: expr
    repeat-expr: number_of_echos * number_of_layers * number_of_columns_in_segment
    doc: |
      Distance values scaled by distance_scaling_factor; multiplicity is
      number_of_echos * number_of_layers * number_of_columns_in_segment.

  - id: intensity
    size: number_of_echos * number_of_layers * number_of_columns_in_segment * 3 / 2
    if: (data_content_echo & 1) != 0
    doc: |
      Packed 12-bit intensity (RSSI) values; present when data_content_echo
      bit 0 is set. Multiplicity is number_of_echos * number_of_layers *
      number_of_columns_in_segment.

  - id: pulse_width
    size: number_of_echos * number_of_layers * number_of_columns_in_segment
    if: (data_content_echo & 2) != 0
    doc: |
      Echo pulse width in 0.125 ns units; present when data_content_echo bit 1
      is set. Multiplicity is number_of_echos * number_of_layers *
      number_of_columns_in_segment.

  - id: echo_properties
    size: number_of_echos * number_of_layers * number_of_columns_in_segment
    if: (data_content_echo & 4) != 0
    doc: |
      Per-echo flags, bits 0..7; present when data_content_echo bit 2 is set.
