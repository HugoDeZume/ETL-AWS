# Crea una VPC con un bloque CIDR de 10.0.0.0/16
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Crea una subred dentro de la VPC en la zona de disponibilidad us-west-2a y us-west-2b
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
}

# Crea una puerta de enlace de Internet para la VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Crea una tabla de rutas pública para la VPC
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Define una ruta para la tabla de rutas que dirige el tráfico a la puerta de enlace de Internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Asocia la tabla de rutas pública con la primera y segunda subred
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.public.id
}

# Crea un grupo de subredes para Redshift, incluyendo ambas subredes
resource "aws_redshift_subnet_group" "subnet_group" {
  name       = "redshift-subnet-group"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

# Crea un grupo de seguridad para Redshift
resource "aws_security_group" "redshift_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5439
    to_port     = 5439
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
