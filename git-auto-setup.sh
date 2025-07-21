#!/bin/bash

echo "🔧 Git + GitHub Auto Setup Script (with .env support)"

# Load environment variables safely
if [ ! -f .env ]; then
  echo "❌ .env file not found. Please create one."
  exit 1
fi

set -a
source .env
set +a

# Check required variables
if [[ -z "$GITHUB_TOKEN" || -z "$GIT_USERNAME" || -z "$GIT_EMAIL" || -z "$GITHUB_USERNAME" || -z "$REPO_NAME" ]]; then
  echo "❌ Missing variables in .env. Please check all required keys."
  exit 1
fi

echo "✅ Loaded environment variables."

# Initialize Git if not already
if [ ! -d .git ]; then
  git init
  echo "📁 Initialized new Git repo."
fi

# Set Git local config
git config user.name "$GIT_USERNAME"
git config user.email "$GIT_EMAIL"
echo "✅ Git user configured for this project."

# Create GitHub repo via API
echo "📡 Creating repo '$REPO_NAME' on GitHub..."

create_response=$(curl -s -o response.json -w "%{http_code}" \
  -X POST https://api.github.com/user/repos \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d "{\"name\":\"$REPO_NAME\", \"private\":$PRIVATE}")

if [ "$create_response" -eq 201 ]; then
  echo "✅ GitHub repo created."
elif [ "$create_response" -eq 422 ]; then
  echo "⚠️ Repo already exists on GitHub."
else
  echo "❌ Failed to create repo. HTTP Status: $create_response"
  cat response.json
  exit 1
fi

# Add remote
remote_url="https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git"
git remote remove origin 2>/dev/null
git remote add origin "$remote_url"
echo "🔗 Remote 'origin' added."

# Commit and push
git add .
git commit -m "🚀 Initial commit"
echo "✅ Initial commit done."

git branch -M main
git push -u origin main

if [ $? -ne 0 ]; then
  echo "⚠️ Push failed. Trying with --force..."
  git push -u origin main --force
fi

echo "🚀 Code pushed to GitHub: https://github.com/$GITHUB_USERNAME/$REPO_NAME"

