
resource "aws_iam_role" "masters_iam_role" {
  name               = join("-",[var.stack_name,"masters-iam-role"])
  assume_role_policy = file("../data/aws_iam_role_policy")
}


resource "aws_iam_instance_profile" "masters_instance_profile" {
  name = join("-",[var.stack_name,"masters-iam-instance-profile"])
  role = aws_iam_role.masters_iam_role.name
}


resource "aws_iam_role_policy" "masters_iam_role_policy" {
  name   = join("-",[var.stack_name,"masters-iam-role-policy"])
  role   = aws_iam_role.masters_iam_role.name
  policy = file("../data/aws_iam_role_policy_masters_policy")
}