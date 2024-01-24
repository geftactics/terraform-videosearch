# video-searcher
Aim is to upload a video clip, then end up with individual video files for each word.

1. Upload video to video s3 bucket. process_video.js runs.
2. MP3 audio is output from step 1 File placed in audio s3 bucket. process_audio.js runs.
3. Audio transcription is output from step 2 and placed in data s3 bucket. process_data.js runs.



### Prerequisites
You will need to ensure that you have installed `terraform` and `make`.

macOS users should use [brew](https://brew.sh): `brew install terraform make`.

You'll need to generate an [AWS access key and secret key](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey), then save these in the `~/.aws/credentials` file:

```
[profile-name]
aws_access_key_id = XXXXXXXXXX
aws_secret_access_key = YYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
```

If it's your first time running, you will need to prepare you environment by running `ENV=dev gmake prep`.


### Build
```
ENV=dev gmake apply
```

### Destroy
```
ENV=dev gmake destroy
```
