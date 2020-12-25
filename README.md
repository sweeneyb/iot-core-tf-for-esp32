# iot-core-tf-for-esp32

Simple terraform project to get up and running with Google's IoT core and an esp32 from sparkfun.  The walkthroughs have a lot of manual setup, but I wanted something more automated.  This is written for tf 0.14.  

I'm using following https://github.com/GoogleCloudPlatform/iot-core-micropython with firmware esp32-idf3-20200902-v1.13.bin.  I've made a few tweaks to the main.py code at https://github.com/sweeneyb/iot-core-micropython/blob/master/main.py

## Usage
```
terraform plan
terraform apply
```
## Notes
This uses your current gcloud CLI session.  Make sure you have billing attached, or the enabling of the cloud iot api's will fail.  The code should look up your billing info and attach it to the project automatically.
