# Home Assistant add-on: OpenV vcontrold to HomA MQTT

## How to use
Once installed, the plugin fetches data from `vcontrold` and pushes it to the [HomA](https://github.com/binarybucks/homA) MQTT topic `/devices/<systemID>/controls/<topic>` by executing the commands provided in the configuration and pushing the returned values into a correnspoding topic for that specific command. A list of all possible commands and formats can be found in **/etc/vcontrold/vito.xml**.

Example: Command `getTempAtp` is executed and its return value is pushed into topic `/devices/123456-vito/controls/Aussentemperatur`.

If you want to set values / write to Vitodens you need to configure the `setcmd` option in the commands setting. Writing to a topic `/devices/<systemID>/controls/<topic>/on` that has the setter command configured as specified in **/etc/vcontrold/vito.xml** will execute the vclient write command.

Example: Writing a value to the topic `/devices/123456-vito/controls/Warmwassertemperatur soll/on` will set the target temperature for hot water to a new value by using the vclient command `setTempWWsoll`. You will be able to see it in `/devices/123456-vito/controls/Warmwassertemperatur soll` in the next readout cycle.

## Configuration

### Add-On Configuration
In the configuration section, you have 2 choices to connect to your **Vitodens** device using an an **Optolink** interface:
1. For a locally connected **Optolink** cable, set the USB/TTY device. The add-on will pass through that USB port run **vcontrold** locally inside docker.
   As the USB device might change it is adviceable to look into `/dev/serial/by-id` and use the device found here e.g. `/dev/serial/by-id/usb-FTDI_FT232R_USB_UART_12345678-if00-port0`.
2. For a remotely running **vcontrold** (e.g. RPi connected to your **Vitodens** device), select its hostname and port (_Vcontrold host/port_). These settings are by default set to localhost:3002.

Select a _refresh rate_ that defines the interval used for polling your device and the _device id_ (typically also seen in the device identifier string) which is used to select the correct mapping for the commands that are executed.

The commands section can be edited and extended in YAML mode, e.g.
```yaml
  commands:
    - command: "getTempRaumRedSollM2"
      setcmd: "setTempRaumRedSollM2"
      type: "INT"
      topic: "Raumtemperatur reduziert soll"
      unit: "°C"
      class: "temperature"
    - command: "getTempRaumNorSollM2"
      setcmd: "setTempRaumNorSollM2"
      type: "INT"
      topic: "Raumtemperatur soll"
      unit: "°C"
      class: "temperature"
```

`command` and `setcmd` can be taken from [vito.xml](rootfs/etc/vcontrold/vito.xml).

`type` can be `INT` for integer, `FLOAT` for decimal values, `FLOAT1` for floats with one decimal place, `STRING` for strings.

`class` is the Home Assistant sensor class like `temperature`, `power` and so on. See [Available device classes](https://developers.home-assistant.io/docs/core/entity/sensor/#available-device-classes).

### Integration into Home Assistant
Integration in Home Assistant is done automatically by the setttings in die `commands` section of the config.

To be able to write (set values) in Home Assistant, manual configuration is needed. First the `setcmd` key must be set in the [add-on configuration](#add-on-configuration) `commands` section. For [numbers](#numbers) (like the hot water in the example above) a slider (or an input box) can be used. For selecting different values a [selector](#selectors) can be used. This is done by creating a helper (or use the input yaml examples below) and an [automation](#automation) (by using a [blueprint](#blueprints)).

#### Numbers
Download and config the silder numbers in [openv_input_numbers.yaml](config/input_numbers/openv_input_numbers.yaml) and put it into `config/input_numbers` folder of your Home Assistant installation.
```shell
curl -L -o openv_input_numbers.yaml \
  https://raw.githubusercontent.com/hass-hmueller01/addon-openv-homa/refs/heads/main/openv-homa/config/input_select/openv_input_numbers.yaml
rsync -av openv_input_numbers.yaml root@<home-assistant-ip>:config/input_numbers/
```
To load these numbers add
```
input_number: !include_dir_merge_named input_numbers
```
in your `configuration.yaml` using `ssh root@<home-assistant-ip>` and e.g. the `vi` editor.

After that you can add the number entity to your dashboard and modify the value.

#### Selectors
Download and config the select inputs in [openv_input_select.yaml](config/input_select/openv_input_select.yaml) and put it into `config/input_select` folder of your Home Assistant installation.
```shell
curl -L -o openv_input_select.yaml \
  https://raw.githubusercontent.com/hass-hmueller01/addon-openv-homa/refs/heads/main/openv-homa/config/input_select/openv_input_select.yaml
rsync -av openv_input_select.yaml root@<home-assistant-ip>:config/input_select/
```
To load these selectors add
```
input_select: !include_dir_merge_named input_select
```
in your `configuration.yaml` using `ssh root@<home-assistant-ip>` and e.g. the `vi` editor.

After that you can add the selector entity to your dashboard and modify the value.

#### Blueprints
Download [mqtt-select-sync.yaml](config/blueprints/automation/openv-homa/mqtt-select-sync.yaml) and [mqtt-slider-sync.yaml](config/blueprints/automation/openv-homa/mqtt-slider-sync.yaml) and put it into `config/blueprints/automation/openv-homa` folder of your Home Assistant installation.
```shell
curl -L -o mqtt-select-sync.yaml \
  https://raw.githubusercontent.com/hass-hmueller01/addon-openv-homa/refs/heads/main/openv-homa/config/blueprints/automation/openv-homa/mqtt-select-sync.yaml
curl -L -o mqtt-slider-sync.yaml \
  https://raw.githubusercontent.com/hass-hmueller01/addon-openv-homa/refs/heads/main/openv-homa/config/blueprints/automation/openv-homa/mqtt-slider-sync.yaml
rsync -av mqtt-select-sync.yaml mqtt-slider-sync.yaml root@<home-assistant-ip>:config/blueprints/automation/openv-homa/
```

#### Automation
The actual work is done by the automation and the vclient_sub runner. To create the automation use the [blueprint](#blueprints) and configure it with the input, the sensor entity and the MQTT topic. After that you will see in the add-on log if the new value gets set.

### Custom vito.xml / vcontrold.xml configuration file

The module use the `config` option (refer to https://developers.home-assistant.io/docs/add-ons/configuration/#add-on-advanced-options) for mounting a custom configuration file. It verifies the existence of a 'vito.xml' and 'vcontrold.xml' file during startup.

Ensure the files are placed in the specified path of your Home Assistant installation:
```
config/vcontrold/vito.xml
config/vcontrold/vcontrold.xml
```

The `vcontrold.xml` should use the tags `#DEBUG#`, `#DEVICEID#` and `#VITOXML#` to use the add-on configuration.
```xml
  <unix>
    <config>
      ...
      <logging>
        <file>/dev/stdout</file>
        <syslog>n</syslog>
        <debug>#DEBUG#</debug>
      </logging>
      <device ID="#DEVICEID#"/>
    </config>
  </unix>
...
  <extern xmlns:xi="http://www.w3.org/2003/XInclude">
    <xi:include href="#VITOXML#" parse="xml"/>
  </extern>
```
