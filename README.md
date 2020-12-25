# iot-core-tf-for-esp32

Simple terraform project to get up and running with Google's IoT core and an esp32 from sparkfun.  The walkthroughs have a lot of manual setup, but I wanted something more automated.  This is written for tf 0.14.  

I'm using following https://github.com/GoogleCloudPlatform/iot-core-micropython with firmware esp32-idf3-20200902-v1.13.bin.  I've made a few tweaks to the main.py code at https://github.com/sweeneyb/iot-core-micropython/blob/master/main.py

## Usage
```
terraform plan
terraform apply
```

### Outputs
As a convenience, an output named cloud-config is generated that should be used as the *google_cloud_config* block in config.py.

The code will also generate & preload the device certificates into the device registry.  So you'll need to run this terraform before making edits to your config.py file.  You'll need to grab private key off the command line, move it into your iot-core-micropython project root, and run utils/decode_rsa.py.  If anyone has insight into how to make those numbers from the private key, I'll update this repo to make that easier.

## Verifying it works
Assuming your apply is clean, and your esp32 is running, you'll want to see it working.  There is a subscription named '''cli-verify''' for just that.  

```
gcloud config set project $(terraform output project-id)
gcloud pubsub subscriptions pull cli-verify  --auto-ack --limit=500
```

## Notes
This uses your current gcloud CLI session.  Make sure you have billing attached, or the enabling of the cloud iot api's will fail.  The code should look up your billing info and attach it to the project automatically.
