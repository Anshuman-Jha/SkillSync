# 🚀 Google Cloud Run Deployment Guide

## Why Google Cloud Run?

**Google Cloud Run is an EXCELLENT choice for your Conversation Canvas project!** Here's why:

✅ **Generous Free Tier**: 2 million requests per month, 360,000 GB-seconds of memory, 180,000 vCPU-seconds  
✅ **Pay-per-use**: Only pay when your app is actually running (no cold start charges)  
✅ **Auto-scaling**: Automatically scales from 0 to 1000+ instances  
✅ **Fast deployments**: 1-2 minutes  
✅ **Automatic HTTPS**: Free SSL certificates  
✅ **No cold starts** (with min instances configuration)  
✅ **Better than Railway**: More generous free tier, better scalability

---

## 📋 Overview

- **Frontend**: Deploy to Vercel (recommended) or Cloud Run
- **Backend**: Deploy to Google Cloud Run
- **Database**: MongoDB Atlas (already configured)

---

## 🎯 Backend Deployment to Google Cloud Run

### Prerequisites

1. **Google Cloud Account**
   - Go to [cloud.google.com](https://cloud.google.com)
   - Sign up (you get $300 free credits for 90 days!)
   - Create a new project (e.g., "conversation-canvas")

2. **Install Google Cloud CLI**
   ```bash
   # For macOS
   brew install --cask google-cloud-sdk
   
   # For Windows
   # Download from https://cloud.google.com/sdk/docs/install
   
   # For Linux
   curl https://sdk.cloud.google.com | bash
   ```

3. **Initialize gcloud**
   ```bash
   # Login to your Google account
   gcloud auth login
   
   # Set your project
   gcloud config set project YOUR_PROJECT_ID
   
   # Enable required APIs
   gcloud services enable run.googleapis.com
   gcloud services enable containerregistry.googleapis.com
   ```

---

### Step 1: Create Dockerfile for Backend

Create a file `backend/Dockerfile`:

```dockerfile
# Use Node.js 20 Alpine for smaller image size
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy source code
COPY . .

# Expose port
EXPOSE 8080

# Start the application
CMD ["npm", "start"]
```

### Step 2: Create .dockerignore

Create `backend/.dockerignore`:

```
node_modules
npm-debug.log
.env
.env.*
.git
.gitignore
README.md
.DS_Store
```

### Step 3: Deploy Backend to Cloud Run

```bash
# Navigate to backend directory
cd backend

# Deploy to Cloud Run (this will build and deploy in one command!)
gcloud run deploy conversation-canvas-backend \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10 \
  --set-env-vars "NODE_ENV=production"
```

> **Note**: The `--source .` flag tells Cloud Run to build from source code directly. No need to build Docker images manually!

### Step 4: Set Environment Variables

After deployment, set your environment variables:

```bash
gcloud run services update conversation-canvas-backend \
  --region us-central1 \
  --set-env-vars "PORT=8080,\
DB_URL=mongodb+srv://your_mongodb_url,\
NODE_ENV=production,\
CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key,\
CLERK_SECRET_KEY=your_clerk_secret_key,\
INNGEST_EVENT_KEY=your_inngest_event_key,\
INNGEST_SIGNING_KEY=your_inngest_signing_key,\
STREAM_API_KEY=your_stream_api_key,\
STREAM_API_SECRET=your_stream_api_secret,\
CLIENT_URL=https://your-frontend-url.vercel.app"
```

**Or**, use the Cloud Console UI:
1. Go to [Cloud Run Console](https://console.cloud.google.com/run)
2. Click on your service
3. Click "EDIT & DEPLOY NEW REVISION"
4. Go to "Variables & Secrets" tab
5. Add all environment variables
6. Click "DEPLOY"

### Step 5: Get Your Backend URL

```bash
gcloud run services describe conversation-canvas-backend \
  --region us-central1 \
  --format 'value(status.url)'
```

Your backend will be available at: `https://conversation-canvas-backend-XXXX-uc.a.run.app`

---

## 🎨 Frontend Deployment

### Option 1: Vercel (Recommended) ⭐

Vercel is the fastest and easiest option for Vite apps.

#### Steps:

1. **Create Vercel Account**
   - Go to [vercel.com](https://vercel.com)
   - Sign up with GitHub

2. **Import Project**
   - Click "Add New Project"
   - Import your GitHub repository

3. **Configure Project**
   - **Root Directory**: `frontend`
   - **Framework Preset**: `Vite`
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`

4. **Environment Variables**
   
   Add these in Vercel dashboard:
   ```
   VITE_CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key
   VITE_API_URL=https://conversation-canvas-backend-XXXX-uc.a.run.app/api
   VITE_STREAM_API_KEY=your_stream_api_key
   ```

5. **Deploy**
   - Click "Deploy"
   - Get your frontend URL (e.g., `https://your-app.vercel.app`)

6. **Update Backend CLIENT_URL**
   - Update Cloud Run backend environment variable `CLIENT_URL` to your Vercel URL
   - Redeploy backend

---

### Option 2: Google Cloud Run (Alternative)

You can also deploy the frontend to Cloud Run if you want everything on GCP.

#### Steps:

1. **Create Dockerfile for Frontend**

Create `frontend/Dockerfile`:

```dockerfile
# Build stage
FROM node:20-alpine as build

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built files to nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
```

2. **Create nginx.conf**

Create `frontend/nginx.conf`:

```nginx
server {
    listen 8080;
    server_name _;
    
    root /usr/share/nginx/html;
    index index.html;
    
    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    # Handle client-side routing
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

3. **Create .dockerignore**

Create `frontend/.dockerignore`:

```
node_modules
dist
.env
.env.*
npm-debug.log
.git
.gitignore
README.md
.DS_Store
```

4. **Deploy to Cloud Run**

```bash
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
  --max-instances 10 \
  --set-env-vars "VITE_CLERK_PUBLISHABLE_KEY=your_key,\
VITE_API_URL=https://your-backend-url/api,\
VITE_STREAM_API_KEY=your_key"
```

---

## 🔐 Environment Variables Checklist

### Backend (Cloud Run)
- [ ] `PORT=8080`
- [ ] `DB_URL` (MongoDB Atlas connection string)
- [ ] `NODE_ENV=production`
- [ ] `CLERK_PUBLISHABLE_KEY`
- [ ] `CLERK_SECRET_KEY`
- [ ] `INNGEST_EVENT_KEY`
- [ ] `INNGEST_SIGNING_KEY`
- [ ] `STREAM_API_KEY`
- [ ] `STREAM_API_SECRET`
- [ ] `CLIENT_URL` (your Vercel or Cloud Run frontend URL)

### Frontend (Vercel or Cloud Run)
- [ ] `VITE_CLERK_PUBLISHABLE_KEY`
- [ ] `VITE_API_URL` (your backend URL + `/api`)
- [ ] `VITE_STREAM_API_KEY`

---

## 🔄 Post-Deployment Steps

1. **Test Your Application**
   - Visit your frontend URL
   - Test authentication (Clerk)
   - Test video calls (Stream)
   - Test all features

2. **Update Clerk Settings**
   - Go to [Clerk Dashboard](https://dashboard.clerk.com)
   - Add your frontend URL to "Allowed Origins"
   - Add redirect URLs

3. **Monitor Deployments**
   - Cloud Run: Check logs with `gcloud run logs tail conversation-canvas-backend --region us-central1`
   - Vercel: Check deployment logs in dashboard

---

## 🚨 Troubleshooting

### CORS Errors
- Ensure `CLIENT_URL` in backend matches your frontend URL exactly
- Check CORS configuration in backend code

### API Connection Issues
- Verify `VITE_API_URL` includes `/api` at the end
- Check backend is running (visit backend URL in browser)
- Check Cloud Run logs: `gcloud run logs tail conversation-canvas-backend --region us-central1`

### Authentication Errors
- Verify Clerk keys are correct in both frontend and backend
- Check Clerk dashboard for allowed origins

### Build Failures
- Check build logs: `gcloud run services describe conversation-canvas-backend --region us-central1`
- Ensure all dependencies are in `package.json`
- Verify Node version compatibility

### Cold Starts
If you experience cold starts (slow first request):

```bash
# Set minimum instances to 1 (keeps at least 1 instance warm)
gcloud run services update conversation-canvas-backend \
  --region us-central1 \
  --min-instances 1
```

> **Note**: This will reduce your free tier usage but eliminates cold starts

---

## 💰 Cost Optimization Tips

1. **Use Free Tier Effectively**
   - Set `--min-instances 0` for low-traffic services
   - Set `--max-instances 10` to prevent unexpected scaling costs
   - Use `--memory 512Mi` or `--memory 256Mi` instead of higher values

2. **Monitor Usage**
   ```bash
   # View Cloud Run metrics
   gcloud run services describe conversation-canvas-backend \
     --region us-central1 \
     --format='value(status.traffic)'
   ```

3. **Set Budget Alerts**
   - Go to [Cloud Console > Billing](https://console.cloud.google.com/billing)
   - Set budget alerts for $5, $10, $20 etc.

4. **Use Regional Deployment**
   - Deploy to `us-central1` or nearest region to reduce costs
   - Avoid multi-region deployments unless needed

---

## 🚀 Continuous Deployment (Optional)

### Automatic Deployment from GitHub

1. **Set up Cloud Build**
   ```bash
   gcloud services enable cloudbuild.googleapis.com
   ```

2. **Create cloudbuild.yaml**

Create `backend/cloudbuild.yaml`:

```yaml
steps:
  # Build the container image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/conversation-canvas-backend', '.']
  
  # Push the container image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/conversation-canvas-backend']
  
  # Deploy to Cloud Run
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: gcloud
    args:
      - 'run'
      - 'deploy'
      - 'conversation-canvas-backend'
      - '--image'
      - 'gcr.io/$PROJECT_ID/conversation-canvas-backend'
      - '--region'
      - 'us-central1'
      - '--platform'
      - 'managed'

images:
  - 'gcr.io/$PROJECT_ID/conversation-canvas-backend'
```

3. **Connect GitHub Repository**
   - Go to [Cloud Build Triggers](https://console.cloud.google.com/cloud-build/triggers)
   - Click "Connect Repository"
   - Follow the steps to connect your GitHub repo
   - Create a trigger to deploy on push to `main` branch

---

## 📊 Comparison: Cloud Run vs Railway vs Vercel

| Feature | Google Cloud Run | Railway | Vercel (Backend) |
|---------|-----------------|---------|------------------|
| **Free Tier** | 2M requests/month | $5/month credit | Not for backend |
| **Deployment Speed** | ⚡ 1-2 min | ⚡ 1-2 min | ⚡ <1 min |
| **Cold Starts** | ⚡ Minimal | ❌ None | ⚡ Minimal |
| **Auto-scaling** | ✅ 0-1000+ | ✅ Limited | ✅ Excellent |
| **Easy Setup** | ⚡ Medium | ✅ Very easy | ✅ Very easy |
| **Custom Domains** | ✅ Free | ✅ Free | ✅ Free |
| **Monitoring** | ✅ Excellent | ✅ Good | ✅ Excellent |
| **Regional Choice** | ✅ 30+ regions | ⚡ Limited | ✅ Global |
| **Price (after free)** | 💰 Pay-per-use | 💰 Fixed | 💰 Pay-per-use |

**Recommendation**: 
- **Best Choice**: Google Cloud Run (most generous free tier, better scalability)
- **Easiest**: Railway or Vercel (simpler setup)
- **Most Control**: Google Cloud Run (full GCP integration)

---

## 💡 Quick Start Commands

### Deploy Backend
```bash
cd backend
gcloud run deploy conversation-canvas-backend \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080
```

### View Logs
```bash
gcloud run logs tail conversation-canvas-backend --region us-central1
```

### Update Environment Variables
```bash
gcloud run services update conversation-canvas-backend \
  --region us-central1 \
  --update-env-vars KEY=VALUE
```

### Redeploy
```bash
cd backend
gcloud run deploy conversation-canvas-backend \
  --source . \
  --region us-central1
```

---

## 🎉 Done!

Your application should now be live and running on Google Cloud Run!

**Frontend**: `https://your-app.vercel.app` (or Cloud Run URL)  
**Backend**: `https://conversation-canvas-backend-XXXX-uc.a.run.app`

**Free Tier Benefits:**
- 2 million requests/month for backend
- Automatic HTTPS
- Global CDN
- Auto-scaling from 0 to thousands of instances
- No cold start charges (unlike AWS Lambda)

If you encounter any issues, check the troubleshooting section or Cloud Run logs!
