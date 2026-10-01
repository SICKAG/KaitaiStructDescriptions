<div align="center">

<img src="doc/SICK-logo.svg" alt="SICK Logo" width="300"/>
<br/>
<img src="doc/SICK-SDK-icon.svg" alt="SICK Icon" width="90"/>

# KaitaiStructDescriptions

Kaitai Struct format descriptions for the SICK LiDAR Compact Format.
Generate ready-to-use parsers in Python, C#, Java, C++, Go, and more without writing parsing code by hand.

![Language](https://img.shields.io/badge/Language-Kaitai_Struct-005aff)
![Sensors](https://img.shields.io/badge/Sensors-multiScan100_|_multiScan200_|_picoScan100_|_LRS4000-005aff)
[![Maintained](https://img.shields.io/badge/Maintained-yes-005aff)](https://github.com/SICKAG/KaitaiStructDescriptions)
[![Open Issues](https://img.shields.io/github/issues/SICKAG/KaitaiStructDescriptions?label=Open%20Issues&color=005aff)](https://github.com/SICKAG/KaitaiStructDescriptions/issues)

[Quickstart with Python](#quickstart-with-python) • [Web IDE](#web-ide-no-installation-required)

</div>

---

## Format Overview

All compact telegrams share the same outer frame (`compact_frame.ksy`).
The `telegram_type` field selects the payload type:

| Type | Name                             | `.ksy` file                                      | Sensors                             |
| ---: | -------------------------------- | ------------------------------------------------ | ----------------------------------- |
|    1 | Primary Data                    | `type_1_primary_data_spherical_coordinates.ksy`  | picoScan100, multiScan100, LRS4000 |
|    2 | IMU                             | `type_2_imu.ksy`                                 | picoScan100, multiScan100          |
|    3 | Ambient Light                   | `type_3_ambient_light.ksy`                       | multiScan200                       |
|    4 | Encoder                         | `type_4_encoder.ksy`                             | picoScan150                        |
|    6 | Primary Data (multiScan200)     | `type_6_primary_data_multiscan200.ksy`           | multiScan200                       |
|    7 | IMU (standard header)           | `type_7_imu_standard_header.ksy`                 | multiScan200                       |

All `.ksy` files are located in the `formats/` directory.

> **Note:** More details on the individual formats can be found in the respective operating instructions of each sensor.

---

## Architecture

`compact_frame.ksy` is the entry point for all telegram types. It dispatches to
the matching payload type based on `telegram_type`. Types 4, 6, and 7 use the
common header sub-type in `compact_header.ksy`; types 1 and 2 use their own
header layouts, and type 3 uses the common header as well.

```mermaid
flowchart TD
    CF[compact_frame.ksy]
    T1[type_1_primary_data_spherical_coordinates.ksy]
    T2[type_2_imu.ksy]
    T3[type_3_ambient_light.ksy]
    T4[type_4_encoder.ksy]
    T6[type_6_primary_data_multiscan200.ksy]
    T7[type_7_imu_standard_header.ksy]
    CH[compact_header.ksy]

    CF --> T1
    CF --> T2
    CF --> T3
    CF --> T4
    CF --> T6
    CF --> T7

    T6 --> CH
    T7 --> CH
    T4 --> CH
    T3 --> CH
```

---

## Quickstart with Python

### 1. Install the Kaitai Struct Compiler

Download `ksc` from <https://kaitai.io/#download> and add it to your `PATH`.
Java 8 or later is required.

### 2. Generate the Python parser

```bash
kaitai-struct-compiler -t python --outdir . formats/compact_frame.ksy
```

This writes `compact_frame.py` and all imported payload modules into the current directory.

### 3. Install the runtime and parse

```bash
pip install kaitaistruct
```

```python
import socket
from kaitaistruct import KaitaiStream, BytesIO
from compact_frame import CompactFrame

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("", 2115))
raw, _ = sock.recvfrom(65535)

frame = CompactFrame(KaitaiStream(BytesIO(raw)))
print(f"telegram_type : {frame.telegram_type}")
print(f"checksum      : 0x{frame.checksum:08x}")

if frame.telegram_type == 1:
    header = frame.payload.header
    print(f"telegram version : {header.telegram_version}")
    print(f"modules          : {len(frame.payload.module)}")

elif frame.telegram_type == 2:
    imu = frame.payload
    print(f"accel  : x={imu.acceleration.x:.4f}  y={imu.acceleration.y:.4f}  z={imu.acceleration.z:.4f}")
    print(f"gyro   : x={imu.angular_velocity.x:.4f}  y={imu.angular_velocity.y:.4f}  z={imu.angular_velocity.z:.4f}")

elif frame.telegram_type == 3:
    ambient = frame.payload
    print(f"frame number     : {ambient.frame_number}")
    print(f"layers           : {ambient.number_of_layers}")
    print(f"columns          : {ambient.number_of_columns}")
    print(f"pixels           : {len(ambient.ambient_light_data)}")

elif frame.telegram_type == 4:
    enc = frame.payload
    print(f"telegram counter : {enc.header.telegram_counter}")
    print(f"tick count       : {enc.tick_count}")
    print(f"speed            : {enc.speed:.3f}")

elif frame.telegram_type == 6:
    pd = frame.payload
    print(f"telegram counter : {pd.header.telegram_counter}")
    print(f"frame number     : {pd.frame_number}")
    print(f"layers           : {pd.number_of_layers}")
    print(f"columns          : {pd.number_of_columns_in_segment}")

elif frame.telegram_type == 7:
    imu = frame.payload
    print(f"accel  : x={imu.acceleration.x:.4f}  y={imu.acceleration.y:.4f}  z={imu.acceleration.z:.4f}")
    print(f"gyro   : x={imu.angular_velocity.x:.4f}  y={imu.angular_velocity.y:.4f}  z={imu.angular_velocity.z:.4f}")
```

---

## Web IDE (no installation required)

Open the [Kaitai Web IDE](https://ide.kaitai.io/#) in your browser and drag any `.ksy` file from the `formats/` directory onto the page. To generate a parser:

1. Right-click the imported file in the file tree on the left.
2. Select **Generate Parser** and choose your target language.
3. The generated code appears on the right.

---

## Known Issues

### `num_*` style warnings during compilation

When compiling, kaitai-struct-compiler may emit style-guide warnings such as
`use 'num_elevation_angles' instead of 'number_of_layers'` for count fields in
`type_1_primary_data_spherical_coordinates.ksy` and
`type_6_primary_data_multiscan200.ksy`.

These warnings are expected and safe to ignore.

---

## Support

Please open a GitHub issue for bugs or questions.
