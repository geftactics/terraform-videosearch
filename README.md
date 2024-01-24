# video-searcher
Aim is to upload a video clip, then end up with individual video files for each word.

1. Upload video to video s3 bucket... `process_video.js` runs.
2. MP3 audio is output from step 1 File placed in audio s3 bucket. `process_audio.js` runs.
3. Audio transcription is output from step 2 and placed in data s3 bucket. `process_data.js` runs.

```
cd environments/prod
terragrunt plan
terragrunt apply
```