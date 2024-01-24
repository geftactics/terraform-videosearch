'use strict';

const aws = require('aws-sdk');
const s3 = new aws.S3();
const fs = require('fs');
const childProcess = require('child_process');

exports.handler = async (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  const bucket = event.Records[0].s3.bucket.name;
  const key = event.Records[0].s3.object.key;
  const newKey = key.split('.')[0];
  const str = newKey.lastIndexOf('/');
  const instance = newKey.substring(str + 1);

  const params = {
    Bucket: bucket,
    Key: key,
  };

  // TODO: ugly testing stuff, this obvz needs doing properly without hard-coded badness
  const inputKey = instance + '.mp4';
  const inputParams = {
    Bucket: 'video-searcher-video-prod',
    Key: 'inputvideo/' + inputKey,
  };

  try {
    const data = await s3.getObject(params).promise();
    const body = JSON.parse(data.Body.toString());

    const wordcounts = {};

    // Download the original video from S3 to /tmp
    const originalVideoPath = `/tmp/${inputKey}`;
    console.log(`Downloading ${inputKey} from ${bucket}`);

    // Wrap the S3 download operation in a Promise
    await new Promise((resolve, reject) => {
      s3.getObject(inputParams)
        .createReadStream()
        .on('error', (err) => {
          console.error('Error during getObject:', err);
          reject(err);
        })
        .pipe(fs.createWriteStream(originalVideoPath))
        .on('error', (err) => {
          console.error('Error writing to ' + originalVideoPath, err);
          reject(err);
        })
        .on('finish', () => {
          console.log('File written to ' + originalVideoPath);
          resolve();
        });
    });

    console.log(`Download complete!`);

    for (let i = 0; i < body.results.items.length; i++) {
      if (
        body.results.items[i].start_time !== undefined &&
        body.results.items[i].end_time !== undefined &&
        body.results.items[i].alternatives[0].confidence !== undefined &&
        body.results.items[i].alternatives[0].content !== undefined &&
        body.results.items[i].type !== undefined
      ) {
        const content = body.results.items[i].alternatives[0].content;
        // add some buffer on for clear word boundaries
        var start = parseFloat(body.results.items[i].start_time) - 0.1;
        var end = parseFloat(body.results.items[i].end_time) + 0.1;

        if (start<0) {
          start = 0
        }

        if (!wordcounts[content]) {
          wordcounts[content] = 1;
        } else {
          wordcounts[content]++;
        }

        console.log(`ffmpeg: ${instance}/${content}_${wordcounts[content]}.mp4`);



        // Use ffmpeg to extract the specified time range
        // no endocoding const ffmpegCommand = `/opt/bin/ffmpeg -i ${originalVideoPath} -ss ${start} -to ${end} -c:v copy -c:a copy -loglevel error "/tmp/${content}_${wordcounts[content]}.mp4"`;
        const ffmpegCommand = `/opt/bin/ffmpeg -i ${originalVideoPath} -ss ${start} -to ${end} -c:v libx264 -c:a aac -force_key_frames ${start} -loglevel error "/tmp/${content}_${wordcounts[content]}.mp4"`;

        childProcess.execSync(ffmpegCommand);
        console.log('Video trimmed successfully.');

        // Upload the trimmed video to the output S3 bucket
        const outputParams = {
          Bucket: event.Records[0].s3.bucket.name,
          Key: `${instance}/${content}_${wordcounts[content]}.mp4`,
          Body: require('fs').createReadStream(`/tmp/${content}_${wordcounts[content]}.mp4`),
        };
        await s3.upload(outputParams).promise();
        console.log(`Uploaded trimmed video to ${bucket}/${instance}/${content}_${wordcounts[content]}.mp4`);
      }
    }

    return {
      statusCode: 200,
      body: JSON.stringify('Video trimming and uploading completed successfully'),
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify('Error processing video'),
    };
  }
};
