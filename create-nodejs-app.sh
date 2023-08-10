#!/bin/bash

# Function to exit script with an error message
exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Read GitHub access token securely
read -sp "Enter your GitHub access token: " GITHUB_TOKEN
echo

# Validate token
if [[ -z "$GITHUB_TOKEN" ]]; then
    exit_with_error "GitHub access token is required."
fi

# Read repo name from user
read -p "Enter a name for the new repository: " NEW_REPO_NAME

# Validate repo name
if [[ -z "$NEW_REPO_NAME" ]]; then
    exit_with_error "Repository name is required."
fi

# Create the GitHub repository
curl_response=$(curl -u "ike10:$GITHUB_TOKEN" -X POST -H "Content-Type: application/json" -d '{"name":"'$NEW_REPO_NAME'"}' https://api.github.com/user/repos)
if [[ $? -ne 0 ]]; then
    exit_with_error "Failed to create GitHub repository."
fi

# Extract the repository URL from the response
REPO_URL=$(echo "$curl_response" | grep -o '"clone_url":"[^"]*' | sed 's/"clone_url":"//')

# Create the project directory
mkdir $NEW_REPO_NAME
cd $NEW_REPO_NAME

# Initialize a new Node.js project
npm init -y

# Create initial files
echo "console.log('Hello, Node.js!');" > index.js

# Create README file
echo "# $NEW_REPO_NAME" > README.md
echo "This is a simple Node.js application." >> README.md
echo "To run the project, follow these steps:" >> README.md
echo "1. Install Node.js if not already installed." >> README.md
echo "2. Clone this repository: \`git clone $REPO_URL\`" >> README.md
echo "3. Navigate to the project directory: \`cd $NEW_REPO_NAME\`" >> README.md
echo "4. Run the project: \`node index.js\`" >> README.md

# Initialize Git repository
git init
git add .
git commit -m "Initial commit"

# Add remote repository and push
git remote add origin $REPO_URL
git branch -M main
git push -u origin main

echo "Node.js app '$NEW_REPO_NAME' created and pushed to GitHub repository."
