# Deployment Guide for awsopenclaw.com

This guide covers deploying the OpenClaw on AWS website to your GoDaddy domain.

## Option 1: GitHub Pages (Recommended - Free & Easy)

### Step 1: Enable GitHub Pages

1. Go to your repository: https://github.com/Vivek0712/openclaw-on-aws-website
2. Click **Settings** → **Pages**
3. Under **Source**, select **Deploy from a branch**
4. Choose **main** branch and **/ (root)** folder
5. Click **Save**

Your site will be available at: `https://vivek0712.github.io/openclaw-on-aws-website/`

### Step 2: Configure Custom Domain in GitHub Pages

1. In the same Pages settings, add your custom domain: `awsopenclaw.com`
2. GitHub will create a `.github/CNAME` file automatically
3. Check "Enforce HTTPS" (after DNS propagates)

### Step 3: Configure DNS in GoDaddy

1. Log in to GoDaddy
2. Go to **My Products** → **DNS** for `awsopenclaw.com`
3. Add/Update these DNS records:

**For root domain (awsopenclaw.com):**
```
Type: A
Name: @
Value: 185.199.108.153
TTL: 600

Type: A
Name: @
Value: 185.199.109.153
TTL: 600

Type: A
Name: @
Value: 185.199.110.153
TTL: 600

Type: A
Name: @
Value: 185.199.111.153
TTL: 600
```

**For www subdomain (www.awsopenclaw.com):**
```
Type: CNAME
Name: www
Value: vivek0712.github.io
TTL: 600
```

4. Save changes

### Step 4: Wait for DNS Propagation

- DNS changes can take 24-48 hours to propagate
- Check status: https://www.whatsmydns.net/#A/awsopenclaw.com
- Once propagated, GitHub will automatically enable HTTPS

---

## Option 2: Netlify (Recommended - Fast & Free)

### Step 1: Deploy to Netlify

1. Go to https://netlify.com and sign up/login
2. Click **Add new site** → **Import an existing project**
3. Connect to GitHub and select `openclaw-on-aws-website`
4. Build settings:
   - **Build command:** (leave empty)
   - **Publish directory:** `/` (root)
5. Click **Deploy site**

### Step 2: Configure Custom Domain

1. Go to **Site settings** → **Domain management**
2. Click **Add custom domain**
3. Enter `awsopenclaw.com`
4. Follow Netlify's DNS instructions

### Step 3: Update GoDaddy DNS

Netlify will provide DNS records. Typically:
```
Type: A
Name: @
Value: [Netlify IP - provided in dashboard]

Type: CNAME
Name: www
Value: [your-site].netlify.app
```

---

## Option 3: Vercel (Recommended - Fast & Free)

### Step 1: Deploy to Vercel

1. Go to https://vercel.com and sign up/login
2. Click **Add New Project**
3. Import `openclaw-on-aws-website` from GitHub
4. Framework Preset: **Other**
5. Click **Deploy**

### Step 2: Configure Custom Domain

1. Go to **Settings** → **Domains**
2. Add `awsopenclaw.com`
3. Follow Vercel's DNS instructions

### Step 3: Update GoDaddy DNS

Vercel will provide DNS records to add in GoDaddy.

---

## Option 4: AWS S3 + CloudFront (For AWS Integration)

### Step 1: Create S3 Bucket

```bash
aws s3 mb s3://awsopenclaw.com --region us-east-1
aws s3 website s3://awsopenclaw.com --index-document index.html
```

### Step 2: Upload Files

```bash
cd openclaw-on-aws-website
aws s3 sync . s3://awsopenclaw.com --exclude ".git/*" --exclude "*.md"
```

### Step 3: Configure CloudFront

1. Create CloudFront distribution
2. Origin: S3 bucket `awsopenclaw.com`
3. Alternate domain: `awsopenclaw.com`
4. SSL certificate: Request from ACM

### Step 4: Update GoDaddy DNS

Point to CloudFront distribution:
```
Type: A (or CNAME)
Name: @
Value: [CloudFront domain]
```

---

## Option 5: GoDaddy Web Hosting (Traditional)

If you have GoDaddy web hosting:

### Step 1: Access via FTP/File Manager

1. Log in to GoDaddy
2. Go to **My Products** → **Web Hosting** → **Manage**
3. Use **File Manager** or **FTP**

### Step 2: Upload Files

Upload all files from `openclaw-on-aws-website/` to:
- `/public_html/` (for root domain)
- Or `/public_html/www/` (if using www subdomain)

### Step 3: Ensure index.html is in Root

Make sure `index.html` is accessible at the root of your domain.

---

## Recommended: GitHub Pages

**Why GitHub Pages?**
- ✅ Free forever
- ✅ Automatic HTTPS
- ✅ Easy updates (just push to GitHub)
- ✅ Fast CDN
- ✅ Custom domain support
- ✅ No server management

**Quick Setup:**
1. Push code to GitHub (already done)
2. Enable Pages in repository settings
3. Add custom domain
4. Update GoDaddy DNS
5. Wait 24-48 hours for propagation

---

## Testing Your Deployment

After deployment, test:
- ✅ https://awsopenclaw.com (should load)
- ✅ https://www.awsopenclaw.com (should redirect or load)
- ✅ All links work
- ✅ Mobile responsive
- ✅ HTTPS enabled

---

## Troubleshooting

**DNS not working?**
- Wait 24-48 hours for full propagation
- Clear DNS cache: `sudo dscacheutil -flushcache` (Mac) or `ipconfig /flushdns` (Windows)
- Check DNS: https://www.whatsmydns.net

**HTTPS not working?**
- Wait for DNS to fully propagate
- Ensure "Enforce HTTPS" is enabled in hosting provider
- SSL certificates can take a few hours to provision

**Files not updating?**
- Clear browser cache
- Check if hosting provider has caching (disable or clear)
- Verify files are pushed to GitHub

---

## Need Help?

- GitHub Pages Docs: https://docs.github.com/en/pages
- Netlify Docs: https://docs.netlify.com
- Vercel Docs: https://vercel.com/docs
- GoDaddy Support: https://www.godaddy.com/help

