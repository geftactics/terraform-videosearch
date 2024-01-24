data "aws_iam_policy_document" "this" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
    effect = "Allow"
  }
  statement {
    actions   = ["s3:*"]
    resources = [
      aws_s3_bucket.video.arn, 
      aws_s3_bucket.audio.arn, 
      aws_s3_bucket.data.arn, 
      "${aws_s3_bucket.video.arn}/*", 
      "${aws_s3_bucket.audio.arn}/*",
      "${aws_s3_bucket.data.arn}/*"
      ]
    effect = "Allow"
  }
  statement {
    actions   = ["elastictranscoder:CreateJob"]
    resources = ["arn:aws:elastictranscoder:*"]
    effect = "Allow"
  }
  statement {
    actions   = ["transcribe:StartTranscriptionJob"]
    resources = ["arn:aws:transcribe:*"]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "elastictranscoder.amazonaws.com", "cloudsearch.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name = "${var.product}-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_policy" "this" {
  name        = "${var.product}-${var.env}"
  policy      = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role = aws_iam_role.this.name
}