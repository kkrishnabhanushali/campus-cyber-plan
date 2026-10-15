# Campus Cybersecurity Platform (Gantt + PERT) - DevSecOps Lab
Run locally: `docker build -t campus-cyber-plan . && docker run -p 8080:8080 campus-cyber-plan` then open http://localhost:8080
Test: `sh test.sh` | Scan: `trivy fs .` and `trivy image campus-cyber-plan`
AWS: `cd terraform && terraform init && terraform apply`
