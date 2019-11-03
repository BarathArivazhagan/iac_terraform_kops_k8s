resource "aws_iam_role" "nodes_iam_role" {
  name               =  join("-",[var.stack_name,"nodes-iam-role"])
  assume_role_policy = file("data/aws_iam_role_nodes_policy")
}


resource "aws_iam_instance_profile" "nodes_iam_instance_profile" {
  name =  join("-",[var.stack_name,"nodes-iam-instance-profile"])
  role = aws_iam_role.nodes_iam_role.name
}




resource "aws_iam_role_policy" "nodes-demo-k8s-local" {
  name   =  join("-",[var.stack_name,"nodes-iam-role-policy"])
  role   = aws_iam_role.nodes_iam_role.name
  policy = file("data/aws_iam_role_policy_nodes_policy")
}
