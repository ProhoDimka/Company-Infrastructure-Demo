data "aws_iam_user" "k8s" {
  user_name = var.k8s_iam_user_name
}

resource "aws_iam_access_key" "k8s" {
  user = data.aws_iam_user.k8s.user_name
}