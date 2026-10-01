# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-10-01

### Added

- Added support for telegram type 3 (ambient light)
- Added support for telegram type 6 (primary data of multiScan200)
- Added support for telegram type 7 (IMU with standard header)

### Changed

- Documented every field of telegram types 3 and 6

## [1.2.0] - 2026-06-23

### Added

- Extended README.md

### Changed

- Moved standard header to separate file

## [1.1.0] - 2026-05-17

### Added

- Added support for telegram type 2 (IMU)
- Added support for telegram type 4 (Encoder)

## [1.0.0] - 2024-09-10

### Added

- Includes Kaitai Struct .ksy file to generate a CompactFrame deserializer.
- Description how to generate code
