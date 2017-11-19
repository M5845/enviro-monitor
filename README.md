# Enviro-Monitor

Toy project.

- recording temperature using Raspberry Pi
- upload recordings to Google Sheet
- visualisation with R and
    - [x] ggplot
    - [x] shiny
    - [ ] shiny tabs for temperatur course during month and day

## Run Shiny

    cd src/
    Rscript 03-viz.R
    Rscript 04-shiny-ui.R



## Recoding Temperature

    bash src/01-read-sensors.sh # reads sensors values based
    bash src/02-google.sh # upload to google sheet

### cfg_google.yaml

Requires access to Google APIs. Enviro-Monitor uses
[OAuth2](https://developers.google.com/identity/protocols/OAuth2) to fetch and
store a token for ClientID and Secret. ClientID and secret must be specified in
`cfg_google.yaml`. To create token run:

    perl src/google_create_session.pl -config data/cfg_google.yaml

Token is saved to path specified in `session`.

#### Options

    spreadsheet

Name of spreadsheet

    worksheet

Name of worksheet

    worksheet-use-data

If 1, creates new worksheet for every month (example: 17-10 for Oct 2017).

    session

Token file.

### cfg_sensors.yaml

    id

ID of sensor. Used to find sensor.

    cable

Description used in spreadsheet.


    description

Description used in vizualisation

    type

Type of sensor (temp|humidity|pressure).

    sensor

Name of sensor (dallas|BMP180|AM2302|onBoard)

### Requires

Some scripts:

- [DHT](https://github.com/technion/lol_dht22)
- [BMP180](https://learn.adafruit.com/using-the-bmp085-with-raspberry-pi/using-the-adafruit-bmp-python-library)

Paths to scripts are currently hardcoded in lib/Sensor.pm

