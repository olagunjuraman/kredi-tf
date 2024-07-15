resource "aws_eks_cluster" "kredi_cluster" {
  name     = "kredi-cluster"
  role_arn = aws_iam_role.kredi_eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.kredi_subnet1.id, aws_subnet.kredi_subnet2.id]
  }
}

resource "aws_eks_node_group" "kredi_node_group" {
  cluster_name    = aws_eks_cluster.kredi_cluster.name
  node_group_name = "kredi-node-group"
  node_role_arn   = aws_iam_role.kredi_eks_node_role.arn
  subnet_ids      = [aws_subnet.kredi_subnet2.id, aws_subnet.kredi_subnet3.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

   depends_on = [
    aws_iam_role_policy_attachment.kredi_eks_worker_node_policy,
    aws_iam_role_policy_attachment.kredi_eks_cni_policy,
    aws_iam_role_policy_attachment.kredi_eks_ec2_policy,
  ]
}