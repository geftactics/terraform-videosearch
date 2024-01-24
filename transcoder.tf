resource "aws_elastictranscoder_pipeline" "this" {
  input_bucket  = aws_s3_bucket.video.id
  output_bucket = aws_s3_bucket.audio.id
  name          = "${var.product}-${var.env}"
  role          = aws_iam_role.this.arn
}