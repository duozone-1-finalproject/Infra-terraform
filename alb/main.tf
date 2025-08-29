# 1. ALB가 사용할 보안 그룹 생성
# 인터넷에서 오는 HTTP/HTTPS 요청을 허용
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# 2. 워커 노드 보안 그룹에 ALB로부터의 트래픽 허용 규칙 추가
resource "aws_security_group_rule" "allow_alb_to_nodes" {
  type                     = "ingress"
  protocol                 = "-1" # 모든 프로토콜
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = var.node_security_group_id
}

# 3. AWS Load Balancer Controller Helm 차트 배포
resource "helm_release" "aws_alb_ingress_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = var.alb_controller_version

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}

# 4. Kubernetes Ingress 리소스 생성 (HTTPS 리디렉션 포함)
resource "kubernetes_ingress_v1" "main_ingress" {
  depends_on = [helm_release.aws_alb_ingress_controller]

  metadata {
    name      = "main-ingress"
    namespace = var.ingress_namespace
    annotations = {
      "kubernetes.io/ingress.class"       = "alb"
      "alb.ingress.kubernetes.io/scheme"    = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/listen-ports"  = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/certificate-arn" = var.acm_certificate_arn
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/security-groups" = aws_security_group.alb_sg.name
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = var.backend_service_name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}