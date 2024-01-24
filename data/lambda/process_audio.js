'use strict';

let outputbucket = process.env.outputbucket

var aws = require('aws-sdk');
var s3 = new aws.S3();
var transcribeservice = new aws.TranscribeService({apiVersion: '2017-10-26'});

exports.handler = (event, context, callback) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    var bucket = event.Records[0].s3.bucket.name;
    var key = event.Records[0].s3.object.key;    
    var newKey = key.split('.')[0];
    var str = newKey.lastIndexOf("/");
    newKey = newKey.substring(str+1);
    
    var inputaudiolocation = "https://s3.amazonaws.com/" + bucket + "/inputaudio/";
    var mp3URL = inputaudiolocation+newKey+".mp3";
    var params = {
        LanguageCode: "en-US", /* required */
        Media: { /* required */
          MediaFileUri: mp3URL
        },
        MediaFormat: "mp3", /* required */
        TranscriptionJobName: newKey, /* required */
        MediaSampleRateHertz: 44100,
        OutputBucketName: outputbucket
      };
      transcribeservice.startTranscriptionJob(params, function(err, data){
      if (err){
       console.log('Received event:Error = ',err);
      } else {
       console.log('Received event:Success = ',data);
      }
     });
};