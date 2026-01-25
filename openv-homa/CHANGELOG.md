<!-- https://developers.home-assistant.io/docs/add-ons/presentation#keeping-a-changelog -->
# Changelog

All changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]
### Added
- Implemented writing values (vclient_sub)
- Added getTempWWsoll and setTempWWsoll

## [1.0.1] - 2026-01-18
### Changed
- Cleanup unused translations
- Using https://github.com/hass-hmueller01/hass-addon-helper.git

## [1.0.0] - 2025-12-08
- Removed armhf, armv7, i386 architectures as removed in home-assistant/builder 2025.11.0

## [0.1.10] - 2025-11-09
### Fixed
- Using custom configuration file faild setting user-specified values a second time

## [0.1.9] - 2025-10-08
- Added and used homasystem_config and homacontrol_config functions

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
