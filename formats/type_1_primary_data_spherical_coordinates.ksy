meta:
  id: type_1_primary_data_spherical_coordinates
  endian: le
  bit-endian: be

doc: |
  Compact Format Type 1 - Primary Data Spherical Coordinates
  Sensors: picoScan100, multiScan100, LRS4000.
  Supports telegram_version 3 and 4.
  Version 4 adds distance_scaling_factor in module metadata.

seq:
  - id: header
    type: compactheader
  - id: module
    if: header.size_module_0 > 0
    type: compactmodule
    repeat: until
    repeat-until: _.metadata.next_module_size == 0

types:
  compactheader:
    seq:
      - id: telegram_counter
        type: u8
        doc: |
          Counts all telegrams sent since the device was switched on.
          The counter starts at 1.

      - id: transmit_timestamp
        type: u8
        doc: Unix timestamp [us] at transmit time.

      - id: telegram_version
        type: u4
        valid:
          min: 3
          max: 4

      - id: size_module_0
        type: u4
        doc: Size of the first module to be read.

  compactmodule:
    seq:
      - id: metadata
        type: metadata

      - id: beams
        type: beam
        repeat: expr
        repeat-expr: metadata.number_of_beams_per_scan
        doc: |
          First, a list with entries for beams is created,
          which has the length metadata.number_of_beams_per_scan.
          Then metadata.number_of_lines_in_module entries are made for each beam,
          which contain the line information (echo etc.).

  metadata:
    seq:
      - id: segment_counter
        type: u8

      - id: frame_number
        type: u8
        doc: Counts the number of full revolutions since the device was started.

      - id: sender_id
        type: u4
        doc: |
          Device serial number.
          It can be used on the recipient side to detect which sensor the data was sent from.

      - id: number_of_lines_in_module
        type: u4

      - id: number_of_beams_per_scan
        type: u4
        doc: |
          Number of beams per scan from one layer.
          Scans from all layers in a module have the same number of beams.

      - id: number_of_echos_per_beam
        type: u4

      - id: timestamp_start
        type: u8
        repeat: expr
        repeat-expr: number_of_lines_in_module
        doc: |
          Array of acquisition times for the first beam of each scan in the current module in us.
          The device's internal time base is used.

      - id: timestamp_stop
        type: u8
        repeat: expr
        repeat-expr: number_of_lines_in_module
        doc: |
          Array of acquisition times for the last beam of each scan in the current module in us.
          The device's internal time base is used.

      - id: phi
        type: f4
        repeat: expr
        repeat-expr: number_of_lines_in_module
        doc: Array of elevation angles in radians of each layer in the current module.

      - id: theta_start
        type: f4
        repeat: expr
        repeat-expr: number_of_lines_in_module
        doc: |
          Array of azimuth angles in radians for the first beam
          of each scan of a layer in the current module.

      - id: theta_stop
        type: f4
        repeat: expr
        repeat-expr: number_of_lines_in_module
        doc: |
          Array of azimuth angles in radians for the last beam
          of each scan of a layer in the current module.

      - id: distance_scaling_factor
        if: _parent._parent.header.telegram_version >= 4
        type: f4
        doc: |
          This factor is used to scale the distance values in the beam data to be able to
          represent values above 65535 mm with 16 bits or, alternatively, a sub-millimeter resolution.

      - id: next_module_size
        type: u4
        doc: Size of the next module, or 0 if the current module is the last one.

      - id: reserved
        type: u1

      - id: data_content_echos
        type: data_content_echos
        doc: Bitmask indicating which echo data (distance, RSSI) is present.

      - id: data_content_beams
        type: data_content_beams
        doc: Bitmask indicating which beam data (azimuth, properties) is present.

      - id: reserved1
        type: u1
    instances:
      theta_start_deg:
        value: theta_start[0]  * 180.0 / 3.141592653589
      theta_stop_deg:
        value: theta_stop[0]  * 180.0 / 3.141592653589

  data_content_echos:
    seq:
      - id: reserved
        type: b6
      - id: rssi
        type: b1
      - id: distance
        type: b1

  data_content_beams:
    seq:
      - id: reserved
        type: b6
      - id: azimuth_angles
        type: b1
      - id: beam_properties
        type: b1

  beam:
    seq:
      - id: lines
        type: measurement_data
        repeat: expr
        repeat-expr: _parent.metadata.number_of_lines_in_module

  measurement_data:
    seq:
      - id: echos
        type: echo
        repeat: expr
        repeat-expr: _parent._parent.metadata.number_of_echos_per_beam

      - id: theta_3
        if: _parent._parent.metadata.data_content_beams.azimuth_angles and (_parent._parent._parent.header.telegram_version < 4)
        type: u2
        doc: Azimuth angle for v3 (serialized before properties; see errata).
        doc-ref: https://supportportal.sick.com/trouble-shooting/multiscan-v111-twist-compact-data-format/

      - id: properties
        if: _parent._parent.metadata.data_content_beams.beam_properties
        type: beam_properties

      - id: theta_4
        if: _parent._parent.metadata.data_content_beams.azimuth_angles and (_parent._parent._parent.header.telegram_version >= 4)
        type: u2
        doc: Azimuth angle for v4 (serialized after properties).
    instances:
      theta:
        value: '_parent._parent._parent.header.telegram_version >= 4 ? theta_4 : theta_3'
        doc: Azimuth uint; to radians = (theta - 16384) / 5215.
      theta_rad:
        value: (theta.as<f4> - 16384.0) / 5215.0
      theta_deg:
        value: theta_rad * 180.0 / 3.141592653589

  echo:
    seq:
      - id: distance_raw
        if: _parent._parent._parent.metadata.data_content_echos.distance
        type: u2
        doc: Raw distance; apply distance_scaling_factor for mm.

      - id: rssi
        if: _parent._parent._parent.metadata.data_content_echos.rssi
        type: u2
        doc: |
          The RSSI is a dimensionless quantity. The values can fall within the complete
          value range between 0 and (2^16)-1, whereby it is possible that the maximum value
          is rarely or even never reached.
    instances:
      distance:
        value: '_parent._parent._parent._parent.header.telegram_version >= 4 ? _parent._parent._parent.metadata.distance_scaling_factor * distance_raw : distance_raw'
        doc: Distance in mm.

  beam_properties:
    seq:
      - id: reserved
        type: b7
      - id: reflector
        type: b1
