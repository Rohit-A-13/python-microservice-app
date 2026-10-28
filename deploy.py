import subprocess
import sys
import os

def run_command(command, cwd=None, env=None):
    """Runs a shell command and streams the output to the console."""
    print(f"\n🚀 Running: {command}")
    try:
        # shell=True is required on Windows to run .bat/.cmd and find executables in PATH
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            shell=True,
            cwd=cwd,
            text=True,
            env=env
        )
        
        # Stream output line by line
        for line in process.stdout:
            print(line, end="")
            
        process.wait()
        
        if process.returncode != 0:
            print(f"\n❌ Command failed with exit code {process.returncode}")
            sys.exit(1)
            
    except Exception as e:
        print(f"\n❌ Failed to execute command: {e}")
        sys.exit(1)

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    tf_dir = os.path.join(base_dir, "terraform")

    print("🌟 Starting Local-GitOps-Python-Microservice Deployment")

    # 1. Start Minikube
    run_command(
        "minikube start -p gitops-local --driver=docker --cpus=4 --memory=6144 "
        "--kubernetes-version=v1.30.0 "
        "--addons=default-storageclass,storage-provisioner,ingress "
        "--insecure-registry=localhost:5000"
    )

    # 2. Point Terraform to Minikube's internal kubectl
    # This fixes the API discovery 404 error
    print("\n🔧 Configuring environment to use Minikube's kubectl...")
    env = os.environ.copy()
    # Force Terraform to use the kubectl that matches the cluster
    env["KUBECTL_BIN"] = "minikube kubectl --" 

    # 3. Initialize Terraform
    run_command("terraform init", cwd=tf_dir, env=env)

    # 4. Apply Terraform
    run_command("terraform apply -auto-approve", cwd=tf_dir, env=env)

    print("\n✅ Infrastructure provisioning complete!")
    print("You can now proceed to Phase B: Setting up the Python App and Jenkins.")

if __name__ == "__main__":
    main()