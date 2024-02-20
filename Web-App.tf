data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


# IAM role with policy

resource "aws_iam_role" "EC2_role" {
  name = "EC2_role"

#Permission are written in JSON - can be found in AWS
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

#This is my Read permissions on all EC2 instances policy
resource "aws_iam_policy" "EC2-policy" {
  name        = "EC2-policy"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# EC2 full access policy attachment
#This is an attachment of policy to the role
resource "aws_iam_policy_attachment" "ec2-attach" {
  name       = "ec2-attach"
  roles      = [aws_iam_role.EC2_role.name]
  policy_arn = aws_iam_policy.EC2-policy.arn
}

#Attach role to instance profile

# resource "aws_iam_instance_profile" "ec2role" {
#   name = "attached ec2role"
#   role = aws_iam_role.EC2_role.name
# }



# Bastion Host


resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet1.id
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
}

resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Security group for the bastion host"
  vpc_id      = aws_vpc.the_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}


# Public Instance
# resource "aws_instance" "public_instance" {
#   ami                         = data.aws_ami.ubuntu.id
#   instance_type               = var.instance_type
#   subnet_id                   = aws_subnet.public_subnet1.id
#   vpc_security_group_ids      = [aws_security_group.web-sg.id]
#   associate_public_ip_address = true
#   key_name                    = aws_key_pair.deployer.key_name


#   tags = {
#     Name = "my-web-ec2"
#   }
# }

# resource "aws_instance" "private_instance" {
#   ami                         = data.aws_ami.ubuntu.id
#   instance_type               = var.instance_type
#   subnet_id                   = aws_subnet.private_subnet1.id
#   vpc_security_group_ids      = [aws_security_group.bastion_host_sg.id]
#   associate_public_ip_address = true
#   key_name                    = aws_key_pair.deployer.key_name
#   user_data                   = file("web-script.sh")


#   tags = {
#     Name = "my-app-ec2"
#   }
# }



# # create ebs volume
# resource "aws_ebs_volume" "ebs-private" {
#   availability_zone = "us-east-2a"
#   size              = 8

#   tags = {
#     Name = "my-terraform volume"
#   }
# }

# resource "aws_volume_attachment" "ebs_att" {
#   device_name = "/dev/sdh"
#   volume_id   = aws_ebs_volume.ebs-private.id
#   instance_id = aws_instance.private_instance.id
# }




# SG for web tier

resource "aws_security_group" "web-sg" {
  description = "security group for web tier"
  vpc_id      = aws_vpc.the_vpc.id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]

  }

  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]

  }

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 special value indicating that all protocols are allowed.
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_vpc_security_group_ingress_rule" "allow_ipv4" {
#   security_group_id = aws_security_group.web-sg.id
#   cidr_ipv4 = aws_vpc.the_vpc.cidr_block
#   from_port = 443
#   ip_protocol = "tcp"
#   to_port = 443

# }



# # SG App tier (Bastion Host)
# resource "aws_security_group" "bastion_host_sg" {
#   description = "SSH access on port 22"
#   vpc_id      = aws_vpc.the_vpc.id

#   ingress {
#     description = "ssh access"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "TCP"
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1" # -1 special value indicating that all protocols are allowed.
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


# ASG for web tier: 

#Launch template


resource "aws_launch_template" "my-launch-temp" {
  # name_prefix   = var.name_prefix
  name          = var.launch_temp_name
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  user_data     = filebase64("web-script.sh")
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2role.name
  }
  
  # vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name                    = aws_key_pair.deployer.key_name
  # security_group_names = [aws_security_group.web-sg.id]

  

  network_interfaces {
    associate_public_ip_address = true
    security_groups    = [aws_security_group.web-sg.id]
  }

   tags = {
    Name = "my-app-ec2"
  }

}
  
resource "aws_iam_instance_profile" "ec2role" {
  name = "ec2role"
  role = aws_iam_role.EC2_role.name
}

  # block_device_mappings {
  #   device_name = "/dev/sdf"

  #   ebs {
  #     volume_size = 8
  #   }
  # }


# Private auto-scaling group
resource "aws_autoscaling_group" "asg" {
  # availability_zones = ["${var.region}a", "${var.region}b"]
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_zone_identifier = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]


  launch_template {
    id      = aws_launch_template.my-launch-temp.id
    version = "$Latest"
  }
}



# create keypair 
resource "aws_key_pair" "deployer" {
  key_name   = "project"
  public_key = file("./yes.pub")
}


