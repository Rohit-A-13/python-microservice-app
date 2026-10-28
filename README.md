markdown
# Local-GitOps-Python-Microservice

A complete, production-style **CI/CD & GitOps pipeline** that runs **100% locally** on a single machine. No cloud accounts (AWS, GCP, Azure) or cloud credits are required.

This project demonstrates Infrastructure as Code (IaC), Continuous Integration, Continuous Deployment, and GitOps principles using industry-standard tools.

## 🏗️ Architecture

The workflow is fully automated from a `git push` to a running application in Kubernetes.

1. **Developer** pushes code to the `python-microservice-app` repository.
2. **Jenkins** (running in Docker) catches the webhook, runs `pytest`, builds a Docker image, and pushes it to a local registry.
3. **Jenkins** then updates the `gitops-manifests` repository with the new image tag.
4. **Argo CD** (running in Minikube) detects the change in the `gitops-manifests` repo and automatically syncs the new deployment to the Kubernetes cluster.
5. **Kubernetes** pulls the new image and updates the running application.

## 🧰 Tech Stack

* **Infrastructure:** Terraform, Minikube, Docker
* **CI/CD:** Jenkins, Git, GitHub
* **CD (GitOps):** Argo CD
* **Application:** Python (FastAPI), Pytest
* **Container Registry:** Local Docker Registry (`registry:2`)

## 📁 Repository Structure

```text
local-gitops-python-microservice/
├── app/                      # FastAPI application code and tests
├── terraform/                # IaC to provision Minikube, Namespaces, Registry, and Argo CD
├── gitops-manifests/         # Kubernetes YAML files watched by Argo CD (separate repo)
├── jenkins/                  # Docker Compose file for running Jenkins locally
├── Dockerfile                # Builds the Python application image
├── requirements.txt          # Python dependencies
└── deploy.py                 # Python orchestration script to bootstrap the infrastructure
🚀 Getting Started (Local Setup)
Prerequisites
Make sure you have the following installed on your Windows/Mac/Linux machine:

Docker Desktop

Minikube

Terraform

kubectl

Python 3.12+

1. Provision Infrastructure
Run the Python orchestration script to start Minikube, provision the registry, and install Argo CD via Terraform:

bash
python deploy.py
2. Start Jenkins
bash
cd jenkins
docker compose up -d
Access Jenkins at http://localhost:8080.

3. Configure Jenkins
Install the Docker Pipeline and GitHub Integration plugins.

Add a Secret Text credential with ID github-pat (Your GitHub Personal Access Token with repo scope).

Create a new Pipeline job pointing to your python-microservice-app GitHub repo, with the Script Path set to jenkins/Jenkinsfile.

4. Configure the Local Registry Bridge
Because Jenkins runs in a container and Kubernetes runs inside Minikube, start a port-forward to allow Jenkins to push images to the local registry:

bash
kubectl port-forward -n local-app svc/local-registry 5000:5000
5. Run the Pipeline!
Click Build Now in Jenkins. The pipeline will test, build, push, and update the GitOps repo. Argo CD will then automatically deploy the app to Minikube.

6. Access the Application
To access the app from your host machine, port-forward the Python service:

bash
kubectl port-forward -n local-app svc/python-microservice 8081:80
Open your browser and go to: http://localhost:8081/health. You should see {"status":"healthy"}.

🧠 Key Learnings & Troubleshooting
Docker-in-Docker (DinD) limits: Jenkins required the Docker socket to be mounted (/var/run/docker.sock) to build images.

Network isolation: Passing images from a host-level Docker daemon to a Minikube cluster required minikube image load to bypass local registry routing issues in Windows.

Git Auth: Resolving GitHub 403 errors during automated pushes required correctly scoping Personal Access Tokens and clearing local git credential caches.

State Drift: Argo CD's selfHeal: true guarantees that any manual changes to Kubernetes (e.g., kubectl scale) are instantly reverted to match Git.

🤝 Contributing
This project was built for educational and portfolio purposes. Feel free to fork it, break it, and fix it!

text

### Step 3: Push the README to GitHub
Save the file, close Notepad, and go back to your PowerShell terminal.

Run these exact commands to push your new README to the app repository:
```powershell
git add README.md
git commit -m "Docs: Add comprehensive README"
git push origin main
