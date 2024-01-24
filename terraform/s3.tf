resource "aws_s3_bucket" "video" {
  bucket = "${var.product}-video-${var.environment}"
  force_destroy = true
  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "audio" {
  bucket = "${var.product}-audio-${var.environment}"
  force_destroy = true
  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "data" {
  bucket = "${var.product}-data-${var.environment}"
  force_destroy = true
  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_notification" "video" {
  bucket = aws_s3_bucket.video.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.video.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "inputvideo/"
  }
  depends_on = [aws_lambda_permission.video]
}

resource "aws_s3_bucket_notification" "audio" {
  bucket = aws_s3_bucket.audio.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.audio.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "inputaudio/"
  }
  depends_on = [aws_lambda_permission.audio]
}

resource "aws_s3_bucket_notification" "data" {
  bucket = aws_s3_bucket.data.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.data.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }
  depends_on = [aws_lambda_permission.data]
}

resource "aws_lambda_permission" "video" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.video.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.video.arn
}

resource "aws_lambda_permission" "audio" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.audio.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.audio.arn
}

resource "aws_lambda_permission" "data" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.data.arn
}

resource "aws_s3_object" "inputvideo" {
  bucket = aws_s3_bucket.video.id
  key    = "inputvideo/"
}

resource "aws_s3_object" "inputaudio" {
  bucket = aws_s3_bucket.audio.id
  key    = "inputaudio/"
}

resource "aws_s3_bucket_website_configuration" "video" {
  bucket = aws_s3_bucket.video.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_website_configuration" "audio" {
  bucket = aws_s3_bucket.audio.id
  index_document {
    suffix = "index.html"
  }
}

