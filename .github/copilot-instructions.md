---
applyTo: "**"
---

# Copilot Instructions — SICK LiDAR Compact Format — Kaitai Struct Descriptions

## Purpose

This repository contains **Kaitai Struct format descriptions** (`.ksy`) for the **SICK LiDAR Compact Format**. These descriptions allow you to generate parsers in multiple programming languages without writing any parsing code by hand.

## Key Conventions

- All compact frames have the outer layout: `magic(4) | command_id(u32le) | payload | CRC32(u32le)`.
- CRC32 covers `magic + command_id + payload` (everything except the last 4 bytes).
- `.ksy` `meta.id` values are the Python class names used in `tests/generated/`.
- Payload `.ksy` files use `meta.id` values.