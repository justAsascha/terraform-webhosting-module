###############
# Lambda@edge #
###############
resource "aws_iam_role" "lambda_edge_exec" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# we need inline code, because environment  
# variables are not supported for lamba@edge
data "archive_file" "lambda_zip_inline" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_inline.zip"
  source {
    content  = <<EOF
exports.handler = async (event, context, callback) => {
    const request = event.Records[0].cf.request;
    const headers = request.headers;

    const user = "${var.basic_auth_username}";
    const pass = "${var.basic_auth_password}";

    const basicAuthentication = 'Basic ' + new Buffer(user + ':' + pass).toString('base64');

    if (typeof headers.authorization == 'undefined' || headers.authorization[0].value != basicAuthentication) {
        const body = 'You are not authorized to enter';
        const response = {
            status: '401',
            statusDescription: 'Unauthorized',
            body: body,
            headers: {
                'www-authenticate': [{ key: 'WWW-Authenticate', value: 'Basic' }]
            },
        };
        callback(null, response);
    }
    callback(null, request);
};
EOF
    filename = "main.js"
  }
}

resource "aws_lambda_function" "lambda_edge" {
  function_name    = "edge_basic_auth_guard"
  handler          = "main.handler"
  runtime          = "nodejs12.x"
  role             = aws_iam_role.lambda_edge_exec.arn
  filename         = data.archive_file.lambda_zip_inline.output_path
  source_code_hash = data.archive_file.lambda_zip_inline.output_base64sha256
  provider         = aws.useast1
  publish          = true
}
