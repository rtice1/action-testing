# Evolve Devops Assessment

## DESCRIPTION
Candidates will be tasked with delivering the Acceptance Criteria listed below. Once the candidate's user has been granted access to the project, they will have 48 hrs to push their changes. Access to the project will be revoked after the 48 hr window has passed.

After the assessment has been submitted it will be reviewed by the Evolve DevOps team.

## ACCEPTANCE CRITERIA
- Deploy an S3 bucket to AWS using Terraform. Configure the following in the Terraform:
  - S3 encryption
  - Bucket policy only allowing Secure Transport (https only)
- Containerize a simple Python application (included in the project as `app.py`), using a tool of the candidates choice
- Deploy the aforementioned Python application to Kubernetes using the candidate’s CI/CD method of choice. Configure the following values for the deployment:
  - 3 replicas
  - Setup Kubernetes Service
    - Type: ClusterIP
    - Runs on port 8080

## BONUS POINTS FOR...
- writing a Gitlab-ci.yml file
- using Helm to deploy to k8s
