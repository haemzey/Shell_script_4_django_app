set -o pipefail 

REPO_URL="https://github.com/haemzey/deploy_django_app.git"
REPO_DIR="deploy_django_app"

clone_pull() {
  if [ -d "$REPO_DIR" ]; then
  echo "repo already exist -- pulling latest changes"
  cd "$REPO_DIR" 
  else
  git clone "$REPO_URL" && cd "$REPO_DIR"
  fi
}

dependency() {
  sudo apt update 
  sudo apt upgrade -y
  sudo apt install docker.io docker-compose-plugin nginx -y
} 
  
restart() {
  sudo systemctl enable docker --now 
  sudo systemctl enable nginx --now 
}

env_file() {
  if [ ! -f ".env" ]; then
  echo ".env is not present, it must be provided seprately"
  echo "copy from CI secrets before deployment started"
  return 1
  fi
}

echo "***** DEPLOYMENT STARTED *****"

deploy() {
  docker-compose up -d 
}

if ! clone_pull; then 
echo "cloning and pulling the repo failed"
exit 1
fi

if ! dependency; then
echo "dependencies installation failed"
exit 1
fi

if ! restart; then
echo "docker system service failed"
exit 1
fi

if ! env_file; then
echo ".env file not found"
exit 1 
fi

if ! deploy; then
echo "deployment failed"
exit 1
fi

echo "***** DEPLOYMENT ENDED *****"