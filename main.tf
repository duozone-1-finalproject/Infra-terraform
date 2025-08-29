# --------------------------------------------------------------------------------------------------
# Module Calls
# 이 파일은 vpc, eks, alb, rds 모듈을 호출하고 모듈 간 출력을 입력으로 전달하여
# 전체 인프라를 오케스트레이션하는 역할을 합니다.
# --------------------------------------------------------------------------------------------------

module "vpc" {
  source = "./vpc"
  # VPC 모듈의 변수들은 ./vpc/variables.tf에 정의된 기본값을 사용합니다.
}

module "eks" {
  source = "./eks"

  # vpc 모듈의 출력을 eks 모듈의 입력으로 전달합니다.
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

module "alb" {
  source = "./alb"

  # vpc와 eks 모듈의 출력을 alb 모듈의 입력으로 전달합니다.
  vpc_id                 = module.vpc.vpc_id
  node_security_group_id = module.eks.node_security_group_id
  cluster_name           = module.eks.cluster_name
  acm_certificate_arn    = var.acm_certificate_arn
}

module "rds" {
  count = var.deploy_rds ? 1 : 0

  source = "./rds"

  # vpc와 eks 모듈의 출력을 rds 모듈의 입력으로 전달합니다.
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  node_sg_id      = module.eks.node_security_group_id
}