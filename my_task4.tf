provider "aws" {
region = "ap-south-1"
profile = "azeem"
}

resource "tls_private_key" "AzeemKeyPair" {
  algorithm = "RSA"
}
resource "aws_key_pair" "generated_key" {    
  key_name   = "AzeemKeyPair"
  public_key = "${tls_private_key.AzeemKeyPair.public_key_openssh}"


  depends_on = [
    tls_private_key.AzeemKeyPair
  ]
}

resource "local_file" "key-file" {
  content  = "${tls_private_key.AzeemKeyPair.private_key_pem}"
  filename = "AzeemKeyPair.pem"


  depends_on = [
    tls_private_key.AzeemKeyPair
  ]
}

resource "aws_vpc" "myVPC" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "myVPC"
  }
}

resource "aws_security_group" "Security_Group_Word_Press" {
  name        = "Security_Group_Word_Press"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "${aws_vpc.myVPC.id}"


  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Security_Group_Word_Press"
  }
}

resource "aws_security_group" "Security_Group_BastionHost" {
  name        = "Security_Group_BastionHost"
  description = "ssh_bh"
  vpc_id      = "${aws_vpc.myVPC.id}"


  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Security_Group_BastionHost"
  }
}

resource "aws_security_group" "Security_Group_MySQL" {
  name        = "Security_Group_MySQL"
  description = "mysql"
  vpc_id      = "${aws_vpc.myVPC.id}"


  ingress {
    description = "mysql"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [ "${aws_security_group.Security_Group_BastionHost.id}" ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "Security_Group_MySQL"
  }
}       

resource "aws_subnet" "My_Public_Subnet" {
  vpc_id            = "${aws_vpc.myVPC.id}"
  availability_zone = "ap-south-1a"
  cidr_block        = "192.168.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "My_Public_Subnet"
  }
}

resource "aws_internet_gateway" "My_IG" {
  vpc_id = "${aws_vpc.myVPC.id}"
  tags = {
    Name = "My_IG"
  }
}
resource "aws_route_table" "my_route_table" {
  vpc_id = "${aws_vpc.myVPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.My_IG.id}"
  }
  tags = {
    Name = "my_route_table"
  }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.My_Public_Subnet.id
  route_table_id = aws_route_table.my_route_table.id
}


resource "aws_subnet" "my_subnet_private" {
  vpc_id            = "${aws_vpc.myVPC.id}"
  availability_zone = "ap-south-1b"
  cidr_block        = "192.168.2.0/24"
  tags = {
    Name = "my_subnet_private"
  }
}

resource "aws_eip" "elastic_ip" {
  vpc      = true
}


resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = "${aws_eip.elastic_ip.id}"
  subnet_id     = "${aws_subnet.My_Public_Subnet.id}"
  depends_on    = [ "aws_nat_gateway.nat_gateway" ]
}

resource "aws_route_table" "nat_gateway_route" {
  vpc_id = "${aws_vpc.myVPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat_gateway.id}"
  }
  tags = {
    Name = "nat_gateway_route"
  }
}
resource "aws_route_table_association" "nat_asso" {
  subnet_id      = aws_subnet.my_subnet_private.id
  route_table_id = aws_route_table.nat_gateway_route.id
}


resource "aws_instance" "WP_OS" {
  ami           = "ami-7e257211"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
  subnet_id     = "${aws_subnet.My_Public_Subnet.id}"
  vpc_security_group_ids = [ "${aws_security_group.Security_Group_Word_Press.id}" ]
  tags = {
    
    Name = "WP_OS"
    
  }
}


resource "aws_instance" "BastionHost_OS" {
  ami           = "ami-0ebc1ac48dfd14136"  
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
  subnet_id     = "${aws_subnet.My_Public_Subnet.id}"
  vpc_security_group_ids = [ "${aws_security_group.Security_Group_BastionHost.id}" ]
  tags = {
    
    Name = "BastionHost_OS"
  }
}


resource "aws_instance" "MySQL_OS" {
  ami           = "ami-0b5bff6d9495eff69"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
  subnet_id     = "${aws_subnet.my_subnet_private.id}"
  vpc_security_group_ids = [ "${aws_security_group.Security_Group_MySQL.id}" ]
  tags = {
    
    Name = "MySQL_OS"
  }
}