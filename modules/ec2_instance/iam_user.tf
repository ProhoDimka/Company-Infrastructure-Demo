resource "aws_iam_user" "main" {
  name = var.instance.iam_username
}

resource "aws_iam_access_key" "main" {
  user = aws_iam_user.main.name
}

resource "aws_iam_policy_attachment" "main" {
  for_each = {
    for iapa in var.instance.iam_additional_policy_attachment : iapa.name => {
      name = iapa.name
      arn  = iapa.arn
    }
  }
  name       = each.value.name
  users = [aws_iam_user.main.name]
  policy_arn = each.value.arn
}

resource "aws_iam_user_policy" "main" {
  count = length(var.instance.iam_additional_user_policy) > 0 ? 1 : 0
  name  = "${aws_iam_user.main.name}_policy"
  user  = aws_iam_user.main.name
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      for statement in var.instance.iam_additional_user_policy : {
        Action   = statement.action,
        Effect   = "Allow",
        Resource = statement.resource,
      }
    ]
  }
  )
}