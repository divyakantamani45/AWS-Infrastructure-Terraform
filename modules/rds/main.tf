resource "aws_db_subnet_group" "this" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.db_subnet_ids
}

resource "aws_db_instance" "this" {
  identifier = "${var.db_name}-instance"
  engine = "postgres"
  engine_version = "17.4"
  instance_class = "db.t4g.micro"
  username = var.db_username
  password = var.db_password
  allocated_storage = 20
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids
}
