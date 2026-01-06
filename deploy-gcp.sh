#!/bin/bash

# Quick Deploy Script for Google Cloud Run
# This script helps you deploy your Conversation Canvas app to Google Cloud Run

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ensure Homebrew path is included (fixes common "command not found" issues on macOS)
export PATH="/opt/homebrew/bin:$PATH"

echo -e "${BLUE}🚀 Conversation Canvas - Google Cloud Run Deployment${NC}"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${YELLOW}⚠️  gcloud CLI not found. Please install it first:${NC}"
    echo "   macOS: brew install --cask google-cloud-sdk"
    echo "   Other: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Get project ID
echo -e "${BLUE}📋 Enter your Google Cloud Project ID:${NC}"
read PROJECT_ID

# Set project
gcloud config set project $PROJECT_ID

# Enable required APIs
echo -e "${GREEN}✅ Enabling required APIs...${NC}"
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Ask which service to deploy
echo ""
echo -e "${BLUE}Which service do you want to deploy?${NC}"
echo "1) Backend only"
echo "2) Frontend only"
echo "3) Both"
read -p "Enter choice (1-3): " CHOICE

# Deploy backend
if [ "$CHOICE" = "1" ] || [ "$CHOICE" = "3" ]; then
    echo ""
    echo -e "${GREEN}🚀 Deploying Backend to Cloud Run...${NC}"
    cd backend
    
    gcloud run deploy conversation-canvas-backend \
      --source . \
      --platform managed \
      --region us-central1 \
      --allow-unauthenticated \
      --port 8080 \
      --memory 512Mi \
      --cpu 1 \
      --min-instances 0 \
      --max-instances 10
    
    # Get backend URL
    BACKEND_URL=$(gcloud run services describe conversation-canvas-backend \
      --region us-central1 \
      --format 'value(status.url)')
    
    echo ""
    echo -e "${GREEN}✅ Backend deployed successfully!${NC}"
    echo -e "${BLUE}Backend URL: ${BACKEND_URL}${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Don't forget to set environment variables in Cloud Console!${NC}"
    
    cd ..
fi

# Deploy frontend
if [ "$CHOICE" = "2" ] || [ "$CHOICE" = "3" ]; then
    echo ""
    echo -e "${GREEN}🚀 Deploying Frontend to Cloud Run...${NC}"
    cd frontend
    
    gcloud run deploy conversation-canvas-frontend \
      --source . \
      --platform managed \
      --region us-central1 \
      --allow-unauthenticated \
      --port 8080 \
      --memory 256Mi \
      --cpu 1 \
      --min-instances 0 \
      --max-instances 10
    
    # Get frontend URL
    FRONTEND_URL=$(gcloud run services describe conversation-canvas-frontend \
      --region us-central1 \
      --format 'value(status.url)')
    
    echo ""
    echo -e "${GREEN}✅ Frontend deployed successfully!${NC}"
    echo -e "${BLUE}Frontend URL: ${FRONTEND_URL}${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Don't forget to set environment variables in Cloud Console!${NC}"
    
    cd ..
fi

echo ""
echo -e "${GREEN}🎉 Deployment complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Set environment variables in Cloud Console"
echo "2. Update Clerk allowed origins"
echo "3. Test your application"
echo ""
echo "View logs: gcloud run logs tail conversation-canvas-backend --region us-central1"
echo "Cloud Console: https://console.cloud.google.com/run"
