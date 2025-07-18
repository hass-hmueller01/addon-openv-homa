<!-- https://developers.home-assistant.io/docs/add-ons/presentation#keeping-a-changelog -->
# Changelog

All changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.3] - 2025-07-06

### Fixed
- Added missing retained flag to 2_mqtt.tmpl MQTT messages

## [0.1.2] - 2025-07-06

### Fixed
- jitterbit/get-changed-files@v1 runner Warning: The `set-output` command is deprecated and will be disabled soon. Replaced by tj-actions/changed-files@v46.0.5

### Removed
- French and Polish translations

## [0.1.1] - 2025-07-01

### Changed
- MQTT messages are retained now

### Updated
- home-assistant/builder 2025.03.0
- docker/login-action 3.4.0

## [0.1.0] - 2025-06-30

- Initial release (ported from [Alexandre-io/homeassistant-vcontrol](https://github.com/Alexandre-io/homeassistant-vcontrol))
