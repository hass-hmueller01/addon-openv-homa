#!/usr/bin/with-contenv bashio
# ==============================================================================
# MQTT Helper Functions
# This script provides helper functions for publishing MQTT messages and
# setting up HomA and Home Assistant integration for the sml2mqtt service.
# Holger Mueller - MIT License 2025
#
# v001 2025-07-17 hmueller01 Initial version
# v002 2025-07-21 hmueller01 Added mosquitto_pub retry logic, added homeassistant_config output
# v003 2025-10-08 hmueller01 Added homasystem_config and homacontrol_config functions
# ==============================================================================

# Create HomA topic string with up to 3 levels of hierarchy
# /devices/$config_systemid/<section>[/<subsection>[/<subsubsection>]]
# Usage: get_topic <section> [<subsection>] [<subsubsection>]
# Requires globals: config_systemid
get_homa_topic() {
    local section="$1"
    local subsection="${2:-}"
    local subsubsection="${3:-}"
    local base="/devices/$config_systemid"

    if [[ -n "$subsection" && -n "$subsubsection" ]]; then
        echo "$base/$section/$subsection/$subsubsection"
    elif [[ -n "$subsection" ]]; then
        echo "$base/$section/$subsection"
    else
        echo "$base/$section"
    fi
}

# Publish a message to an MQTT topic
# Usage: publish_topic <topic> <message> [retain]
# - topic: The MQTT topic to publish to
# - message: The message to publish
# - retain: Optional, whether to retain the message (default: true)
# Requires globals: MQTT_HOST, MQTT_PORT, MQTT_USER, MQTT_PASSWORD
publish_topic() {
    local topic="$1"
    local message="$2"
    local retain="${3:-true}"
    local retain_flag=""
    local errexit=false
    local ret_val

    [[ $retain ]] && retain_flag="-r"
    [[ $- == *e* ]] && errexit=true
    set +e
    while true; do
        # Publish the message to the specified topic
        mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" \
            -t "$topic" -m "$message" $retain_flag
        ret_val=$?
        if [ $ret_val -eq 0 ]; then
            break
        else
            bashio::log.error "publish_topic(): mosquitto_pub returned $ret_val. Retrying in 10s."
            sleep 10
        fi
    done
    [[ $errexit ]] && set -e
}

# Publish system meta information for HomA integration (room, name)
# Usage: homasystem_config _<name> _<room>
# Note: Alwasy removes the leading underscore from parameters! Needed to avoid parameter shifting issues.
# Parameters:
# - name: The HomA system name
# - room: The HomA system room name
# Requires globals: config_systemid
homasystem_config() {
    local name="${1#_}" # Remove leading underscore
    local room="${2#_}"
    publish_topic "$(get_homa_topic meta/name)" "$name"
    publish_topic "$(get_homa_topic meta/room)" "$room"

# Publish control meta information for HomA integration (type, order, unit)
# Usage: homacontrol_config _<control_id> _<type> _order [_<unit>]
# Note: Alwasy removes the leading underscore from parameters! Needed to avoid parameter shifting issues.
# Parameters:
# - control_id: The HomA control_id for the control (/devices/$systemid/controls/$control_id)
# - type: The control type (e.g. text, switch, range)
# - order: The order of the control (integer)
# - unit: The unit of the control (optional)
# Requires globals: config_systemid
homacontrol_config() {
    local control_id="${1#_}" # Remove leading underscore
    local type="${2#_}"
    local order="${3#_}"
    local unit="${4:-}" && unit="${unit#_}" # Default to empty if not provided, remove leading underscore
    publish_topic "$(get_homa_topic controls "$control_id" meta/type)" "$type"
    publish_topic "$(get_homa_topic controls "$control_id" meta/order)" "$order"
    [[ -n "$unit" ]] && publish_topic "$(get_homa_topic controls "$control_id" meta/unit)" " $unit"
}

# Publish a Home Assistant autoconfiguration message for a sensor
# Usage: homeassistant_config _<topic> _<class> [_<unit>] [_<template>]
# Note: Alwasy removes the leading underscore from parameters! Needed to avoid parameter shifting issues.
# Parameters:
# - name: The name of the sensor (e.g. "Current Power")
# - topic: The MQTT topic for the sensor
# - class: The device class (e.g. temperature, power_factor, etc.)
# - unit: The unit of measurement (optional)
# - template: The value template for the sensor (optional)
# Requires globals: config_systemid, config_area, config_device, model_name, manufacturer
homeassistant_config() {
    local name="${1#_}"  # Remove leading underscore
    local topic="${2#_}"
    local class="${3#_}"
    local unit="${4:-}" && unit="${unit#_}" # Default to empty if not provided, remove leading underscore
    local template="${5:-}" && template="${template#_}"

    # Required environment variables: config_systemid, config_area
    local object_id="${config_systemid}-${topic// /-}"
    local ha_topic="homeassistant/sensor/${object_id}/config"

    # Build base payload
    local payload
    payload=$(jq -n \
        --arg device_class "$class" \
        --arg state_topic "/devices/${config_systemid}/controls/${topic}" \
        --arg name "$name" \
        --arg id "$object_id" \
        --arg identifier "$config_systemid" \
        --arg device_name "$config_device" \
        --arg manufacturer $manufacturer \
        --arg model "$model_name" \
        --arg sw_version "$sw_version" \
        --arg area "$config_area" \
        '{
            device_class: $device_class,
            state_topic: $state_topic,
            name: $name,
            unique_id: $id,
            object_id: $id,
            device: {
                identifiers: [$identifier],
                name: $device_name,
                manufacturer: $manufacturer,
                model: $model,
                sw_version: $sw_version,
                suggested_area: $area
            }
        }'
    )

    # Add state_class if needed
    if [[ "$class" == "temperature" || "$class" == "power" || "$class" == "power_factor" ]]; then
        payload=$(echo "$payload" | jq '.state_class = "measurement"')
    elif [[ "$class" == "energy" ]]; then
        payload=$(echo "$payload" | jq '.state_class = "total_increasing"')
    fi

    # Special treatment for _int
    if [[ "$class" == "_int" ]]; then
        payload=$(echo "$payload" | jq 'del(.device_class) | .native_value = "int"')
    fi

    # Special treatment for _datetime
    if [[ "$class" == "_datetime" ]]; then
        payload=$(echo "$payload" | jq 'del(.device_class) | .value_template = "{{ as_datetime(value) }}" | .icon = "mdi:calendar-arrow-right"')
    fi

    # Set unit_of_measurement if available
    if [[ -n "$unit" ]]; then
        payload=$(echo "$payload" | jq --arg unit "$unit" '.unit_of_measurement = $unit')
    fi

    # Set value_template if available
    if [[ -n "$template" ]]; then
        payload=$(echo "$payload" | jq --arg template "$template" '.value_template = $template')
    fi

    # Publish to MQTT
    publish_topic "$ha_topic" "$payload" true
    bashio::log.info "Published Home Assistant config for $name to $ha_topic"
}
