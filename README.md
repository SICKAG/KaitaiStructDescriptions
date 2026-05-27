<div align="center">

<img src="doc/SICK-logo.svg" alt="SICK Logo" width="300"/>
<br/>
<img src="doc/SICK-SDK-icon.svg" alt="SICK Icon" width="90"/>

# KaitaiStructDescriptions

Kaitai Struct format descriptions for the **SICK LiDAR Compact Format** — generate ready-to-use parsers in Python, C#, Java, C++, Go, and more without writing any parsing code by hand.

![Language](https://img.shields.io/badge/Language-Kaitai_Struct-005aff)
![Sensors](https://img.shields.io/badge/Sensors-picoScan100_|_multiScan100_|_LRS4000-005aff)
[![Maintained](https://img.shields.io/badge/Maintained-yes-005aff)](https://github.com/SICKAG/KaitaiStructDescriptions)
[![Open Issues](https://img.shields.io/github/issues/SICKAG/KaitaiStructDescriptions?label=Open%20Issues&color=005aff)](https://github.com/SICKAG/KaitaiStructDescriptions/issues)

[⚡️ Quickstart with Python](#️-quickstart-with-python) • [⚡️ Quickstart with C#](#️-quickstart-with-c) • [🌐 Web IDE](#-web-ide-no-installation-required)

</div>

<details>
  <summary><strong style="font-size:1.25em">Table of contents</strong></summary>

- [📋 Format Overview](#-format-overview)
- [🏛️ Compact Frame Structure](#️-compact-frame-structure)
- [⚡️ Quickstart with Python](#️-quickstart-with-python)
  - [1. Install the Kaitai Struct Compiler](#1-install-the-kaitai-struct-compiler)
  - [2. Generate the Python parser](#2-generate-the-python-parser)
  - [3. Install the runtime and parse](#3-install-the-runtime-and-parse)
- [⚡️ Quickstart with C#](#️-quickstart-with-c)
  - [1. Generate the C# parser](#1-generate-the-c-parser)
  - [2. Receive and parse](#2-receive-and-parse)
- [🌐 Web IDE (no installation required)](#-web-ide-no-installation-required)
- [🛠️ Known Issues](#️-known-issues)
  - [Missing `FromIO` method](#missing-fromio-method)
- [💬 Support](#-support)

</details>

---

## 📋 Format Overview

All compact telegrams share the same outer frame (`compact_frame.ksy`). The `command_id` field selects the payload type:

| Name         | Type (`command_id`) | `.ksy` file               | Sensors                                 |
| ------------ | ------------------- | ------------------------- | --------------------------------------- |
| Primary Data | 1                   | `type_1_primary_data.ksy` | picoScan100, multiScan100, LRS4000      |
| IMU          | 2                   | `type_2_imu.ksy`          | picoScan150, multiScan100, multiScan200 |
| Encoder      | 4                   | `type_4_encoder.ksy`      | picoScan150                             |

---

## 🏛️ Compact Frame Structure

Every telegram — regardless of type — is wrapped in the same outer frame:

```txt
┌──────────────┬──────────────┬──────────────────┬──────────────┐
│  magic       │  command_id  │  payload         │  checksum    │
│  4 bytes     │  u32 le      │  variable        │  u32 le      │
│  0x02020202  │              │                  │  CRC32       │
└──────────────┴──────────────┴──────────────────┴──────────────┘
```

- **magic** — four `0x02` bytes that mark the start of every compact telegram.
- **command_id** — selects the payload type (see table above).
- **payload** — type-specific data; described by the individual `.ksy` files.
- **checksum** — CRC32 computed over `magic + command_id + payload`.

---

## ⚡️ Quickstart with Python

### 1. Install the Kaitai Struct Compiler

Download `ksc` from <https://kaitai.io/#download> and add it to your `PATH`. Java 8 or later is required.

### 2. Generate the Python parser

```bash
ksc -t python formats/compact_frame.ksy
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

# Receive one UDP datagram from the sensor
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("", 2115))          # use the appropriate port for your data type
raw, _ = sock.recvfrom(65535)

frame = CompactFrame(KaitaiStream(BytesIO(raw)))
print(f"command_id : {frame.command_id}")
print(f"checksum   : 0x{frame.checksum:08x}")

if frame.command_id == 1:          # Primary Data
    header = frame.payload.header
    print(f"telegram version : {header.telegram_version}")
    print(f"modules          : {len(frame.payload.module)}")
    for mod in frame.payload.module:
        print(f"  beams: {mod.metadata.num_beams_per_scan}, "
              f"lines: {mod.metadata.num_lines_in_module}, "
              f"echos: {mod.metadata.num_echos_per_beam}")

elif frame.command_id == 2:        # IMU
    imu = frame.payload
    print(f"accel  : x={imu.acceleration.x:.4f}  y={imu.acceleration.y:.4f}  z={imu.acceleration.z:.4f}")
    print(f"gyro   : x={imu.angular_velocity.x:.4f}  y={imu.angular_velocity.y:.4f}  z={imu.angular_velocity.z:.4f}")

elif frame.command_id == 4:        # Encoder
    enc = frame.payload
    print(f"tick counter : {enc.tick_count}")
    print(f"speed        : {enc.speed:.3f}")
```

---

## ⚡️ Quickstart with C\#

### 1. Generate the C# parser

```bash
ksc -t csharp formats/compact_frame.ksy
```

This produces `CompactFrame.cs` and the payload class files. Add them to your project together with the [Kaitai Struct C# runtime](https://github.com/kaitai-io/kaitai_struct_csharp_runtime).

### 2. Receive and parse

```csharp
using System.Net;
using System.Net.Sockets;
using Kaitai;

// Receive one UDP datagram from the sensor
using var udp = new UdpClient(2115);   // use the appropriate port for your data type
var remote = new IPEndPoint(IPAddress.Any, 0);
byte[] raw = udp.Receive(ref remote);

var frame = CompactFrame.FromBytes(raw);
Console.WriteLine($"command_id : {frame.CommandId}");
Console.WriteLine($"checksum   : 0x{frame.Checksum:x8}");

switch (frame.CommandId)
{
    case 1: // Primary Data
        var pd = (PrimaryData)frame.Payload;
        Console.WriteLine($"telegram version : {pd.Header.TelegramVersion}");
        Console.WriteLine($"modules          : {pd.Module.Count}");
        foreach (var mod in pd.Module)
            Console.WriteLine($"  beams={mod.Metadata.NumBeamsPerScan} "
                            + $"lines={mod.Metadata.NumLinesInModule} "
                            + $"echos={mod.Metadata.NumEchosPerBeam}");
        break;

    case 2: // IMU
        var imu = (Imu)frame.Payload;
        Console.WriteLine($"accel : x={imu.Acceleration.X:F4}  y={imu.Acceleration.Y:F4}  z={imu.Acceleration.Z:F4}");
        Console.WriteLine($"gyro  : x={imu.AngularVelocity.X:F4}  y={imu.AngularVelocity.Y:F4}  z={imu.AngularVelocity.Z:F4}");
        break;

    case 4: // Encoder
        var enc = (Encoder)frame.Payload;
        Console.WriteLine($"tick counter : {enc.TickCount}");
        Console.WriteLine($"speed        : {enc.Speed:F3}");
        break;
}
```

---

## 🌐 Web IDE (no installation required)

Open the [Kaitai Web IDE](https://ide.kaitai.io/#) in your browser and drag any `.ksy` file from the `formats/` directory onto the page. To generate a parser:

1. Right-click the imported file in the file tree on the left.
2. Select **Generate Parser** and choose your target language.
3. The generated code appears on the right — copy it into your project.

No Java or `ksc` installation is needed.

---

## 🛠️ Known Issues

### Missing `FromIO` method

Depending on the target language, the generated `CompactFrame` class may not include a `FromIO` method. In Python it is generated automatically; in C# it is not.

To add it manually, insert the following method in `CompactFrame.cs` directly after the existing `FromFile()` method:

```csharp
public static CompactFrame FromIO(Stream io)
{
    return new CompactFrame(new KaitaiStream(io));
}
```

---

## 💬 Support

Please open a GitHub issue for bug or questions.