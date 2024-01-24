data "archive_file" "video" {
  type = "zip"
  source_file = "data/lambda/process_video.js"
  output_path = "/tmp/process-video.zip"
}

resource "aws_lambda_function" "video" {
    function_name    = "${var.product}-process-video-${var.env}"
    role             = aws_iam_role.this.arn
    handler          = "process_video.handler"
    runtime          = "nodejs16.x"
    timeout          = "600"
    filename         = data.archive_file.video.output_path
    source_code_hash = data.archive_file.video.output_base64sha256
    environment {
      variables = {
        pipelineId = aws_elastictranscoder_pipeline.this.id
      }
    }
}

data "archive_file" "audio" {
  type = "zip"
  source_file = "data/lambda/process_audio.js"
  output_path = "/tmp/process-audio.zip"
}

resource "aws_lambda_function" "audio" {
    function_name    = "${var.product}-process-audio-${var.env}"
    role             = aws_iam_role.this.arn
    handler          = "process_audio.handler"
    runtime          = "nodejs16.x"
    timeout          = "600"
    filename         = data.archive_file.audio.output_path
    source_code_hash = data.archive_file.audio.output_base64sha256
    environment {
      variables = {
        outputbucket = aws_s3_bucket.data.id
      }
    }
}

data "archive_file" "data" {
  type = "zip"
  source_file = "data/lambda/process_data.js"
  output_path = "/tmp/process-data.zip"
}

resource "aws_lambda_function" "data" {
    function_name    = "${var.product}-process-data-${var.env}"
    role             = aws_iam_role.this.arn
    handler          = "process_data.handler"
    runtime          = "nodejs16.x"
    timeout          = "900"
    memory_size      = 1024
    filename         = data.archive_file.data.output_path
    source_code_hash = data.archive_file.data.output_base64sha256
    layers           = [aws_lambda_layer_version.ffmpeg.arn]
    environment {
      variables = {
        videoBucketDomain = aws_s3_bucket_website_configuration.video.website_endpoint
      }
    }
}

resource "aws_lambda_layer_version" "ffmpeg" {
  filename         = "data/lambda/ffmpeg.zip"
  layer_name       = "${var.product}-process-data-ffmpeg-layer-${var.env}"
  source_code_hash = filebase64sha256("data/lambda/ffmpeg.zip")
}