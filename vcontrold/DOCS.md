# Home Assistant Add-on: OpenV vcontrold to HomA MQTT add-on

## How to use
Once installed, the plugin fetches data from `vcontrold` and pushes it to the HomA MQTT topic `/devices/<systemID>/controls/<topic>` by executing the commands provided in the configuration and pushing the returned values into a correnspoding topic for that specific command. A list of all possible commands and formats can be found in **/etc/vcontrold/vito.xml**.

Example: Command `getTempAtp` is executed and its return value is pushed into topic `/devices/123456-vito/controls/Aussentemperatur`.

TBD

If you want to set values / write to Vitodens, simply write to a topic that has the man of the setter command as specified in **/etc/vcontrold/vito.xml**.

Example: Writing a value to the topic `openv/setTempWWSoll` will set the target temperature for hot water to a new value. You will be able to see it in `opemv/getTempWWSoll` in the next readout cycle.

## Configuration

### Add-On Configuration
In the configuration section, you have 2 choices to connect to your **Vitodens** device using an an **Optolink** interface:
1. For a locally connected **Optolink** cable, set the USB/TTY device. The add-on will pass through that USB port run **vcontrold** locally inside docker.
2. For a remotely running **vcontrold** (e.g. RPi connected to your **Vitodens** device), select its hostname and port (_Vcontrold host/port_). These settings are by default set to localhost:3002.

Select a _refresh rate_ that defines the interval used for polling your device and the _device id_ (typically also seen in the device identifier string) which is used to select the correct mapping for the commands that are executed.

The commands section can be edited and extended in YAML mode, e.g.
```yaml  commands:
    - command: "getTempRaumRedSollM2"
      type: "FLOAT1"
      topic: "Raumtemperatur reduziert soll"
      unit: "°C"
      class: "temperature"
    - command: "getTempRaumNorSollM2"
      type: "FLOAT1"
      topic: "Raumtemperatur soll"
      unit: "°C"
      class: "temperature"
    - command: "getTempRaumM2"
      type: "FLOAT1"
      topic: "Raumtemperatur"
      unit: "°C"
      class: "temperature"
    - command: "getTempAtp"
      type: "FLOAT1"
      topic: "Aussentemperatur"
      unit: "°C"
      class: "temperature"
    - command: "getTempKist"
      type: "FLOAT1"
      topic: "Kesseltemperatur"
      unit: "°C"
      class: "temperature"
    - command: "getTempKsoll"
      type: "FLOAT1"
      topic: "Kesseltemperatur soll"
      unit: "°C"
      class: "temperature"
    - command: "getTempVListM2"
      type: "FLOAT1"
      topic: "Vorlauftemperatur"
      unit: "°C"
      class: "temperature"
    - command: "getTempVLsollM2"
      type: "FLOAT1"
      topic: "Vorlauftemperatur soll"
      unit: "°C"
      class: "temperature"
    - command: "getTempStp"
      type: "FLOAT1"
      topic: "Warmwassertemperatur"
      unit: "°C"
      class: "temperature"
    - command: "getLeistungIst"
      type: "FLOAT1"
      topic: "Leistung"
      unit: "%"
      class: "power_factor"
    - command: "getPumpeStatusM2"
      type: "STRING"
      topic: "Heizkreispumpe"
      class: "enum"
      template: "{% set mapper = {'0':'AUS', '1':'EIN', '2':'Nacht'} %} {{ mapper[value] if value in mapper else 'Unknown ' + value }}"
    - command: "getBetriebArtM2"
      type: "STRING"
      topic: "Betriebsart"
      class: "enum"
    - command: "getUmschaltventil"
      type: "STRING"
      topic: "Umschaltventil"
      class: "enum"
    - command: "getBrennerStarts"
      type: "INT"
      topic: "Brennerstarts"
      class: "_int"
    - command: "getBrennerStunden1"
      type: "FLOAT"
      topic: "Brennerstunden"
      unit: "h"
      class: "duration"
    - command: "getTempAbgas"
      type: "FLOAT1"
      topic: "Abgastemperatur"
      unit: "°C"
      class: "temperature"
    - command: "getSystemTime"
      type: "STRING"
      topic: "Vito Zeit"
      class: "_datetime"
```

### Integration into Home Assistant
Integration in Home Assistant is done automatically by the setttings in die `commands` section of the config.

To create entities in Home Assistant, you need to configure MQTT sensors - short example with getters and setters (taken from https://github.com/Alexandre-io/homeassistant-vcontrol/issues/7):
```yaml
mqtt:
  binary_sensor:
    - name: "Status Zirklulationspumpe"
      unique_id: "vcontroldgetPumpeStatusZirku"
      state_topic: "openv/getPumpeStatusZirku"
      device_class: running
      value_template: "{% if(value|int == '0') %}OFF{% else %}ON{% endif %}"
      device:
        identifiers: vcontrold
        manufacturer: Viessmann
  sensor:
    - name: "Aussentemperatur"
      unique_id: "vcontroldgetTempA"
      device_class: temperature
      state_topic: "openv/getTempA"
      unit_of_measurement: "°C"
      value_template: |-
        {{ value | round(2) }}
      device:
        identifiers: vcontrold
        manufacturer: Viessmann

  switch:
    - name: "Betriebsart Party"
      unique_id: "vcontroldgetBetriebPartyM1"
      state_topic: "openv/getBetriebPartyM1"
      command_topic: "openv/setBetriebPartyM1"
      device:
        identifiers: vcontrold
        manufacturer: Viessmann
      value_template: | 
        {{ value|round(0) }}
      payload_on: 1
      payload_off: 0
      state_on: 1
      state_off: 0
```
### Custom vito.xml / vcontrold.xml configuration file

The module use the `config` option (refer to https://developers.home-assistant.io/docs/add-ons/configuration/#add-on-advanced-options) for mounting a custom configuration file. It verifies the existence of a 'vito.xml' and 'vcontrold.xml' file during startup.

Ensure the file is placed in the specified path:
```
config/vcontrold/vito.xml
config/vcontrold/vcontrold.xml
```
