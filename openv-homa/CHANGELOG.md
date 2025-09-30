<!-- https://developers.home-assistant.io/docs/add-ons/presentation#keeping-a-changelog -->
# Changelog

All changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.8] - 2025-09-30
- removed bashrc and added echo command in Dockerfile

## [0.1.7] - 2025-07-26
- renamed add-on directory (vcontrold) to slug name (openv-homa)

## [0.1.6] - 2025-07-25
### Changed
- Migrated legacy to s6-overlay to fix the dependencies by using s6-notifyoncheck
- Updated outputs

## [0.1.5] - 2025-07-24
- Not released

## [0.1.4] - 2025-07-22
### Changed
- Migrated to mqtt_helper.sh

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
