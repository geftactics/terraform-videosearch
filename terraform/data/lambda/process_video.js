'use strict';

let pipelineId = process.env.pipelineId

var aws = require("aws-sdk");
var s3 = new aws.S3();

var eltr = new aws.ElasticTranscoder({
 region: "eu-west-1"
});

exports.handler = (event, context, callback) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    
var docClient = new aws.DynamoDB.DocumentClient();
    var bucket = event.Records[0].s3.bucket.name;
    var key = event.Records[0].s3.object.key;

    var audioLocation = "inputaudio";
        
    var newKey = key.split('.')[0];
    var str = newKey.lastIndexOf("/");
    newKey = newKey.substring(str+1);

     var params = {
      PipelineId: pipelineId,
      Input: {
       Key: key,
       FrameRate: "auto",
       Resolution: "auto",
       AspectRatio: "auto",
       Interlaced: "auto",
       Container: "auto"
      },
      Outputs: [
       {
        Key:  audioLocation+'/'+ newKey +".mp3",
        PresetId: "1351620000001-300010"  //mp3 320
       }
      ]
     };
    
     eltr.createJob(params, function(err, data){
      if (err){
       console.log('Received event:Error = ',err);
      } else {
       console.log('Received event:Success =',data);
      }
    });
};

