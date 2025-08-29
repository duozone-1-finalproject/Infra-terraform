# Terraform EKS Cluster Infrastructure

이 프로젝트는 Terraform을 사용하여 AWS에 완전한 EKS 클러스터 인프라를 프로비저닝합니다. VPC, EKS 클러스터, ALB Ingress Controller, 그리고 선택적으로 RDS 데이터베이스를 포함합니다. 전체 인프라는 명확성과 유지보수성을 위해 재사용 가능한 모듈로 구성되어 있습니다.

## 프로젝트 구조
terraform/
├─ main.tf           # 모듈 오케스트레이션
├─ providers.tf      # 프로바이더 설정
├─ variables.tf      # 루트 변수
├─ outputs.tf        # 루트 출력
├─ Readme.md         # 프로젝트 문서
├─ vpc/              # VPC 모듈
├─ eks/              # EKS 모듈
├─ alb/              # ALB 모듈
└─ rds/              # RDS 모듈

*   `main.tf`: 모든 모듈의 배포를 오케스트레이션하는 루트 모듈입니다.
*   `providers.tf`: AWS, Kubernetes, Helm 프로바이더를 설정합니다.
*   `variables.tf`: 루트 레벨의 변수(리전, ACM ARN 등)를 정의합니다.
*   `vpc/`: VPC와 서브넷을 생성하는 모듈입니다.
*   `eks/`: EKS 클러스터와 노드 그룹을 생성하는 모듈입니다.
*   `alb/`: AWS Load Balancer Controller와 메인 Ingress 리소스를 배포하는 모듈입니다.
*   `rds/`: RDS (MariaDB) 인스턴스를 배포하는 모듈입니다 (선택 사항).

## 사전 준비사항

1.  **Terraform CLI**: Terraform이 설치되어 있어야 합니다.
2.  **AWS CLI**: AWS CLI가 설치되고, 적절한 자격증명(Credentials)으로 설정되어 있어야 합니다.
3.  **ACM Certificate**: 사용할 도메인에 대해 `ap-northeast-2` 리전에 미리 발급받은 ACM 인증서가 있어야 합니다. 배포 시 해당 인증서의 ARN이 필요합니다.

## 배포 방법

### 1. 변수 파일 준비

프로젝트 루트 디렉토리에 `terraform.tfvars` 파일을 생성하고, 미리 발급받은 ACM 인증서의 ARN을 추가합니다.

```hcl
# terraform.tfvars
acm_certificate_arn = "arn:aws:acm:ap-northeast-2:123456789012:certificate/your-certificate-id"
```

### 2. Terraform 초기화

프로젝트를 초기화하고 필요한 프로바이더와 모듈을 다운로드하기 위해 아래 명령어를 한 번 실행합니다.

```sh
terraform init
```

### 3. 인프라 배포

배포에는 두 가지 옵션이 있습니다.

**옵션 A: RDS 없이 배포 (기본)**

VPC, EKS 클러스터, ALB 등 RDS를 제외한 모든 리소스를 배포합니다.

```sh
terraform apply
```

**옵션 B: RDS를 포함하여 배포**

`-var` 플래그를 사용하여 RDS 모듈 배포를 활성화합니다.

```sh
terraform apply -var="deploy_rds=true"
```

## 배포 후 확인 절차

### 1. 로컬 Kubeconfig 업데이트

`kubectl`로 클러스터와 상호작용하기 위해 로컬 kubeconfig 파일을 업데이트합니다. 클러스터 이름은 Terraform 출력값을 사용하여 동적으로 가져옵니다.

```sh
# Terraform 출력에서 클러스터 이름 가져오기
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)

# Kubeconfig 업데이트
aws eks --region ap-northeast-2 update-kubeconfig --name $CLUSTER_NAME
```

### 2. ALB 및 Ingress 확인

```sh
# Ingress 상태 확인 (ADDRESS 컬럼에 주소가 나타날 때까지 대기)
kubectl get ingress -A

# Ingress 상세 정보 및 이벤트 확인 
kubectl describe ingress main-ingress -n default
```

## RDS 관리
*   **기존 배포에 RDS 추가하기**:
    ```sh
    terraform apply -var="deploy_rds=true"
    ```
*   **기존 배포에서 RDS 제거하기**:
    ```sh
    terraform apply -var="deploy_rds=false"
    ```

## 전체 리소스 삭제
terraform destroy

### RDS 포함 배포하였을 시
terraform destroy -var="deploy_rds=true"
