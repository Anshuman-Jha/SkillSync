# 🚀 Deployment Guide

This guide will help you deploy your **Conversation Canvas** application smoothly and quickly.

## 📋 Overview

- **Frontend**: Deploy to Vercel
- **Backend**: Deploy to Railway, **Google Cloud Run (recommended)**, or Koyeb
- **Database**: MongoDB Atlas (already configured)

> 💡 **NEW**: Looking for better free tier and scalability? Check out the **[Google Cloud Run Deployment Guide](./DEPLOYMENT_GCP.md)** for detailed instructions!

---

## 🎯 Backend Deployment

### Option 1: Railway (Recommended) ⭐

Railway is fast, has a generous free tier, and deploys in minutes.

#### Steps:

1. **Create Railway Account**
   - Go to [railway.app](https://railway.app)
   - Sign up with GitHub

2. **Deploy Backend**
   ```bash
   # Install Railway CLI (optional, but helpful)
   npm i -g @railway/cli
   
   # Login
   railway login
   ```

3. **Via Railway Dashboard** (Easier)
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your repository
   - Select the `backend` folder as the root directory
   - Railway will auto-detect it's a Node.js app

4. **Configure Environment Variables**
   
   Add these in Railway dashboard under "Variables":
   ```
   PORT=3000
   DB_URL=mongodb+srv://your_mongodb_url
   NODE_ENV=production
   CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key
   CLERK_SECRET_KEY=your_clerk_secret_key
   INNGEST_EVENT_KEY=your_inngest_event_key
   INNGEST_SIGNING_KEY=your_inngest_signing_key
   STREAM_API_KEY=your_stream_api_key
   STREAM_API_SECRET=your_stream_api_secret
   CLIENT_URL=https://your-frontend-url.vercel.app
   ```

5. **Deploy**
   - Railway will automatically deploy
   - Get your backend URL (e.g., `https://xxx.railway.app`)

#### Railway Advantages:
✅ **Fast deployment** (1-2 minutes)  
✅ **$5/month free tier** (500 hours)  
✅ **Automatic HTTPS**  
✅ **Easy monitoring**  
✅ **No cold starts**

---

### Option 2: Koyeb (Alternative)

Koyeb is also fast and has a good free tier.

#### Steps:

1. **Create Koyeb Account**
   - Go to [koyeb.com](https://www.koyeb.com)
   - Sign up with GitHub

2. **Deploy Backend**
   - Click "Create App"
   - Select "GitHub" as source
   - Choose your repository
   - Set root directory to `/backend`
   - Build command: `npm install`
   - Run command: `npm start`
   - Port: `3000`

3. **Add Environment Variables**
   
   Same as Railway (see above)

4. **Deploy**
   - Click "Deploy"
   - Get your backend URL

#### Koyeb Advantages:
✅ **Free tier includes 2 services**  
✅ **Fast deployments**  
✅ **Global CDN**  
✅ **Automatic SSL**

---

## 🎨 Frontend Deployment (Vercel)

### Steps:

1. **Create Vercel Account**
   - Go to [vercel.com](https://vercel.com)
   - Sign up with GitHub

2. **Import Project**
   - Click "Add New Project"
   - Import your GitHub repository
   - Vercel will auto-detect it's a Vite app

3. **Configure Project**
   
   **Root Directory**: `frontend`
   
   **Build Settings**:
   - Framework Preset: `Vite`
   - Build Command: `npm run build`
   - Output Directory: `dist`
   - Install Command: `npm install`

4. **Environment Variables**
   
   Add these in Vercel dashboard:
   ```
   VITE_CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key
   VITE_API_URL=https://your-backend-url.railway.app/api
   VITE_STREAM_API_KEY=your_stream_api_key
   ```

   > ⚠️ **Important**: `VITE_API_URL` should point to your backend URL (from Railway/Koyeb)

5. **Deploy**
   - Click "Deploy"
   - Vercel will build and deploy in ~2 minutes
   - Get your frontend URL (e.g., `https://your-app.vercel.app`)

6. **Update Backend CLIENT_URL**
   - Go back to Railway/Koyeb
   - Update `CLIENT_URL` environment variable to your Vercel URL
   - Redeploy backend

---

## 🔐 Environment Variables Checklist

### Backend (Railway/Koyeb)
- [ ] `PORT`
- [ ] `DB_URL`
- [ ] `NODE_ENV`
- [ ] `CLERK_PUBLISHABLE_KEY`
- [ ] `CLERK_SECRET_KEY`
- [ ] `INNGEST_EVENT_KEY`
- [ ] `INNGEST_SIGNING_KEY`
- [ ] `STREAM_API_KEY`
- [ ] `STREAM_API_SECRET`
- [ ] `CLIENT_URL` (your Vercel URL)

### Frontend (Vercel)
- [ ] `VITE_CLERK_PUBLISHABLE_KEY`
- [ ] `VITE_API_URL` (your backend URL + `/api`)
- [ ] `VITE_STREAM_API_KEY`

---

## 🔄 Post-Deployment Steps

1. **Test Your Application**
   - Visit your Vercel URL
   - Test authentication (Clerk)
   - Test video calls (Stream)
   - Test all features

2. **Update Clerk Settings**
   - Go to [Clerk Dashboard](https://dashboard.clerk.com)
   - Add your Vercel URL to "Allowed Origins"
   - Add redirect URLs

3. **Monitor Deployments**
   - Railway/Koyeb: Check logs for errors
   - Vercel: Check deployment logs

---

## 🚨 Troubleshooting

### CORS Errors
- Ensure `CLIENT_URL` in backend matches your Vercel URL exactly
- Check CORS configuration in backend

### API Connection Issues
- Verify `VITE_API_URL` in Vercel includes `/api` at the end
- Check backend is running (visit backend URL in browser)

### Authentication Errors
- Verify Clerk keys are correct in both frontend and backend
- Check Clerk dashboard for allowed origins

### Build Failures
- Check build logs in Vercel/Railway dashboard
- Ensure all dependencies are in `package.json`
- Verify Node version compatibility

---

## 💡 Tips for Smooth Deployment

1. **Use the same API keys** for both frontend and backend (Clerk, Stream)
2. **Deploy backend first**, then frontend (so you have the backend URL)
3. **Test locally** with production API keys before deploying
4. **Enable automatic deployments** from GitHub main branch
5. **Monitor logs** after first deployment

---

## 📊 Deployment Comparison

| Feature | Google Cloud Run | Railway | Koyeb | Render |
|---------|-----------------|---------|-------|--------|
| **Free Tier** | 2M requests/month | $5/month credit | 2 services free | Limited hours |
| **Deployment Speed** | ⚡ 1-2 min | ⚡ 1-2 min | ⚡ 1-2 min | 🐌 5-10 min |
| **Cold Starts** | ⚡ Minimal | ❌ None | ❌ None | ✅ Yes (slow) |
| **Auto-scaling** | ✅ 0-1000+ | ✅ Limited | ✅ Limited | ✅ Limited |
| **Easy Setup** | ⚡ Medium | ✅ Very easy | ✅ Easy | ✅ Easy |
| **Monitoring** | ✅ Excellent | ✅ Excellent | ✅ Good | ✅ Good |
| **Custom Domains** | ✅ Free | ✅ Free | ✅ Free | ✅ Free |

**Recommendation**: 
- **Best Free Tier**: **Google Cloud Run** (2M requests/month + $300 free credits)
- **Easiest Setup**: **Railway** (fastest to get started)
- **See detailed GCP guide**: [DEPLOYMENT_GCP.md](./DEPLOYMENT_GCP.md)

---

## 🎉 Done!

Your application should now be live and running smoothly! 

**Frontend**: `https://your-app.vercel.app`  
**Backend**: `https://your-backend.railway.app`

If you encounter any issues, check the troubleshooting section above or deployment logs.
