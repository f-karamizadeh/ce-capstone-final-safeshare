data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids      = [module.security.bastion_sg_id]
  associate_public_ip_address = true
  key_name                    = "3tier"

  tags = { Name = "safeshare-bastion" }
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}