data "aws_ami" "bastion" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = [var.ami_owner]
}

resource "aws_security_group" "bastion_ssh" {
  name   = "bastion-host-security-group"
  vpc_id = var.vpc_id

  ingress {
    description = var.bastion_ssh_sec_group_description
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [format("%s/32", var.ip_address)]
  }

  // We do want to e.g. install stuffs in the bastion server
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.default_tags
}

resource "aws_network_interface" "bastion" {
  subnet_id       = var.subnet_id
  security_groups = [aws_security_group.bastion_ssh.id]

  tags = local.default_tags
}

resource "aws_key_pair" "bastion" {
  key_name   = "bastion-ssh-key"
  public_key = file(var.ssh_key_file)

  tags = local.default_tags
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.bastion.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.bastion.key_name

  network_interface {
    network_interface_id = aws_network_interface.bastion.id
    device_index         = 0
  }

  tags = local.default_tags
}

// Update the target security group to allow access from the bastion server
resource "aws_security_group_rule" "target" {
  type                     = "ingress"
  from_port                = var.target_ingress_port
  to_port                  = var.target_ingress_port
  protocol                 = var.target_protocol
  source_security_group_id = aws_security_group.bastion_ssh.id
  security_group_id        = var.target_security_group_id
  description              = var.target_security_rule_description
}
