#!/bin/bash

# setup.sh for bolt.diy on Ubuntu 22.04 LTS
set -e

echo "🚀 Setting up bolt.diy..."

# Check if running on Ubuntu 22.04
if ! grep -q "Ubuntu 22.04" /etc/os-release; then
    echo "⚠️  Warning: This script is designed for Ubuntu 22.04 LTS. Your mileage may vary on other versions."
fi

# Install curl if not present
if ! command -v curl &> /dev/null; then
    echo "📦 Installing curl..."
    sudo apt-get update
    sudo apt-get install -y curl
fi

# Install Node.js v20.x if not present
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js v20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install pnpm if not present and set up PATH
if ! command -v pnpm &> /dev/null; then
    echo "📦 Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    
    # Add pnpm to PATH for current session
    export PNPM_HOME="/root/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    
    # Add pnpm to PATH permanently
    echo 'export PNPM_HOME="/root/.local/share/pnpm"' >> ~/.bashrc
    echo 'export PATH="$PNPM_HOME:$PATH"' >> ~/.bashrc
    
    # Create symlink to make pnpm globally accessible
    sudo ln -s "$PNPM_HOME/pnpm" /usr/local/bin/pnpm
fi

# Clean installation (remove existing node_modules and lock files)
echo "🧹 Cleaning existing installation..."
rm -rf node_modules pnpm-lock.yaml

# Install dependencies
echo "📦 Installing dependencies..."
pnpm install

# Create .env file from example if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from example..."
    cp .env.example .env
    echo "⚠️  Please edit .env file and add your API keys for the LLM providers you want to use."
fi

echo "✅ Setup complete! You can now run the application with:"
echo "   pnpm run dev"
echo ""
echo "🔑 Don't forget to:"
echo "1. Edit the .env file with your API keys"
echo "2. Run 'pnpm run dev' to start the development server"
echo "3. Visit http://localhost:5173 in your browser"
