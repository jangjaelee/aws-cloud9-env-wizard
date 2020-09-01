#  AWS Cloud9 Enviroment Wizard
---

## 작성자
+ 이장재 (cine0831@gmail.com)

## 최종수정일
+ 2020-09-01
  + v1.0

## 요구사항
+ AWS CLI v2

## 기능
+ AWS configure 생성
+ Cloud9 생성 및 삭제
+ Kubernetes Cluster authentication(EKS 클러스터 인증) 및 kube-config 생성
  + Cluster를 생성한 계정이 아닌 다른 계정으로 인증시 AWS configure에 Cluster를 생서한 사용자의 권한이 필요함
+ Kubectl 바이너리 다운로드
+ Terraform dev, prod Enviroment 구성 (git clone from repository)
+ Terraform 바이너리 다운로드 및 .terraformrc 파일 생성

## 사용방법
c9_env_wizard.conf 파일의 variables을 구축하는 환경에 맞게 value를 입력한다.

```
Usage: c9_env_wizard.sh [options] <command>
Options:
    -c or -cloud9
    -k or -kubernetes
    -a or -amazon
    -g or -git
    -t or -terraform
    -h or -help
    
Examples:
    c9_env_wizard.sh -c9 create or delete
    
Description:
    -c or -cloud9           create or delete   |  create Cloud9
    -a or -aws              config             |  configuration for AWS CLI
    -k or -k8s              config or kubectl  |  configuration for Kubernetes (kube config)
    -g or -git              clone              |  clone Terraform source form Git Repository
    -t or -terraform        download           |  downloding a Terraform Bindary
    -h or -help
```
