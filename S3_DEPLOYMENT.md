# S3 Deployment Guide for awsopenclaw.com

Complete step-by-step guide to deploy the website to AWS S3 with CloudFront and configure CNAME in GoDaddy.

## Prerequisites

- AWS CLI installed and configured
- AWS account with S3 and CloudFront access
- Domain `awsopenclaw.com` registered in GoDaddy
- AWS Certificate Manager (ACM) access for SSL certificate

---

## Step 1: Create S3 Bucket

### 1.1 Create the Bucket

```bash
# Set your region (e.g., us-east-1)
export AWS_REGION=us-east-1
export BUCKET_NAME=awsopenclaw.com

# Create bucket
aws s3 mb s3://$BUCKET_NAME --region $AWS_REGION
```

**Or via AWS Console:**
1. Go to S3 Console: https://s3.console.aws.amazon.com
2. Click **Create bucket**
3. Bucket name: `awsopenclaw.com`
4. Region: Choose your preferred region (e.g., `us-east-1`)
5. **Uncheck** "Block all public access" (we'll make it public for website)
6. Click **Create bucket**

### 1.2 Enable Static Website Hosting

```bash
# Enable static website hosting
aws s3 website s3://$BUCKET_NAME \
  --index-document index.html \
  --error-document index.html
```

**Or via AWS Console:**
1. Click on your bucket `awsopenclaw.com`
2. Go to **Properties** tab
3. Scroll to **Static website hosting**
4. Click **Edit**
5. Enable: **Static website hosting**
6. Index document: `index.html`
7. Error document: `index.html` (for SPA routing)
8. Click **Save changes**

### 1.3 Set Bucket Policy (Make Public)

```bash
# Create bucket policy
cat > bucket-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::awsopenclaw.com/*"
    }
  ]
}
EOF

# Apply bucket policy
aws s3api put-bucket-policy \
  --bucket $BUCKET_NAME \
  --policy file://bucket-policy.json
```

**Or via AWS Console:**
1. Go to **Permissions** tab
2. Scroll to **Bucket policy**
3. Click **Edit**
4. Paste this policy (replace `awsopenclaw.com` if different):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::awsopenclaw.com/*"
    }
  ]
}
```

5. Click **Save changes**

### 1.4 Upload Website Files

```bash
# Navigate to website directory
cd /Users/vivekrajaps/openclaw-test/openclaw-on-aws-website

# Upload all files (excluding .git and docs)
aws s3 sync . s3://$BUCKET_NAME \
  --exclude ".git/*" \
  --exclude "*.md" \
  --exclude ".gitignore" \
  --exclude "DEPLOYMENT.md" \
  --exclude "S3_DEPLOYMENT.md" \
  --exclude "QUICK_DEPLOY.md" \
  --cache-control "max-age=3600" \
  --delete
```

**Or via AWS Console:**
1. Click on bucket `awsopenclaw.com`
2. Click **Upload**
3. Add files: `index.html`, `styles.css`, `script.js`
4. Click **Upload**

### 1.5 Test S3 Website (Temporary URL)

After enabling static website hosting, you'll get a website endpoint:
- Format: `http://awsopenclaw.com.s3-website-<region>.amazonaws.com`
- Example: `http://awsopenclaw.com.s3-website-us-east-1.amazonaws.com`

**Note:** This URL is HTTP only. For HTTPS and custom domain, use CloudFront (Step 2).

---

## Step 2: Set Up CloudFront Distribution (Recommended)

CloudFront provides HTTPS, CDN, and custom domain support.

### 2.1 Request SSL Certificate in ACM

**Important:** Request certificate in `us-east-1` region (required for CloudFront)

```bash
# Request certificate
aws acm request-certificate \
  --domain-name awsopenclaw.com \
  --subject-alternative-names "www.awsopenclaw.com" \
  --validation-method DNS \
  --region us-east-1
```

**Or via AWS Console:**
1. Go to ACM: https://console.aws.amazon.com/acm
2. **Important:** Select region `us-east-1` (N. Virginia)
3. Click **Request certificate**
4. Domain names:
   - `awsopenclaw.com`
   - `www.awsopenclaw.com`
5. Validation method: **DNS validation**
6. Click **Request**

### 2.2 Validate Certificate

1. ACM will provide DNS records (CNAME)
2. Go to GoDaddy DNS settings
3. Add the CNAME records provided by ACM
4. Wait for validation (usually 5-30 minutes)
5. Status will change to "Issued"

### 2.3 Create CloudFront Distribution

```bash
# Get S3 website endpoint
S3_ENDPOINT=$(aws s3api get-bucket-website --bucket $BUCKET_NAME --query 'WebsiteConfiguration.RedirectAllRequestsTo' --output text 2>/dev/null || echo "awsopenclaw.com.s3-website-$AWS_REGION.amazonaws.com")

# Create CloudFront distribution (simplified - use console for full config)
# Note: This is complex via CLI, use console instead
```

**Via AWS Console (Recommended):**
1. Go to CloudFront: https://console.aws.amazon.com/cloudfront
2. Click **Create distribution**
3. **Origin settings:**
   - Origin domain: `awsopenclaw.com.s3-website-us-east-1.amazonaws.com`
     - **Important:** Use S3 website endpoint, NOT bucket name
   - Name: `awsopenclaw-s3-origin`
   - Origin path: (leave empty)
   - Origin access: **Origin access control settings (recommended)** or **Public**
4. **Default cache behavior:**
   - Viewer protocol policy: **Redirect HTTP to HTTPS**
   - Allowed HTTP methods: **GET, HEAD**
   - Cache policy: **CachingOptimized** or **CachingDisabled** (for development)
5. **Settings:**
   - Alternate domain names (CNAMEs):
     - `awsopenclaw.com`
     - `www.awsopenclaw.com`
   - SSL certificate: Select your ACM certificate
   - Default root object: `index.html`
   - Custom error responses:
     - HTTP error code: `404`
     - Response page path: `/index.html`
     - HTTP response code: `200`
     - HTTP error code: `403`
     - Response page path: `/index.html`
     - HTTP response code: `200`
6. Click **Create distribution**
7. Wait 5-15 minutes for deployment

### 2.4 Get CloudFront Distribution Domain

After creation, note your CloudFront distribution domain:
- Format: `d1234567890abc.cloudfront.net`
- Example: `d1a2b3c4d5e6f7.cloudfront.net`

---

## Step 3: Configure CNAME in GoDaddy

### 3.1 For Root Domain (awsopenclaw.com)

**Option A: Use CloudFront (Recommended)**

1. Log in to GoDaddy: https://www.godaddy.com
2. Go to **My Products** → Find `awsopenclaw.com` → **DNS**
3. **Remove existing A records** (if any)
4. Add **CNAME record**:
   ```
   Type: CNAME
   Name: @
   Value: d1a2b3c4d5e6f7.cloudfront.net
   TTL: 600 seconds (10 minutes)
   ```
   - Replace `d1a2b3c4d5e6f7.cloudfront.net` with your actual CloudFront domain
5. Click **Save**

**Note:** Some registrars don't support CNAME for root domain (@). If GoDaddy doesn't allow it:

**Option B: Use A Record (ALIAS)**
- GoDaddy may provide an "ALIAS" or "ANAME" record type
- Use that instead of CNAME
- Point to your CloudFront domain

**Option C: Use Route 53 (If you transfer DNS)**
- Transfer DNS to AWS Route 53
- Route 53 supports ALIAS records for root domains
- Point ALIAS to CloudFront distribution

### 3.2 For www Subdomain (www.awsopenclaw.com)

1. In same GoDaddy DNS settings
2. Add **CNAME record**:
   ```
   Type: CNAME
   Name: www
   Value: d1a2b3c4d5e6f7.cloudfront.net
   TTL: 600 seconds
   ```
   - Replace with your CloudFront domain
3. Click **Save**

### 3.3 Alternative: Use S3 Directly (No CloudFront)

If you want to skip CloudFront and use S3 directly:

**For root domain:**
- GoDaddy may not support CNAME for @
- Use A records pointing to S3 IPs (not recommended, changes frequently)
- Better: Use Route 53 or CloudFront

**For www subdomain:**
```
Type: CNAME
Name: www
Value: awsopenclaw.com.s3-website-us-east-1.amazonaws.com
TTL: 600
```

---

## Step 4: Wait for DNS Propagation

1. DNS changes take 24-48 hours to fully propagate
2. Check status: https://www.whatsmydns.net/#CNAME/awsopenclaw.com
3. Test locally:
   ```bash
   # Check DNS resolution
   dig awsopenclaw.com
   nslookup awsopenclaw.com
   ```

---

## Step 5: Verify Deployment

### 5.1 Test URLs

- **S3 Website Endpoint:** `http://awsopenclaw.com.s3-website-us-east-1.amazonaws.com`
- **CloudFront:** `https://d1a2b3c4d5e6f7.cloudfront.net`
- **Custom Domain:** `https://awsopenclaw.com` (after DNS propagates)

### 5.2 Verify HTTPS

- CloudFront automatically provides HTTPS
- Test: `https://awsopenclaw.com`
- Should show valid SSL certificate

### 5.3 Test Website

- All pages load correctly
- CSS and JS files load
- Links work
- Mobile responsive

---

## Step 6: Automation Script

Create a deployment script for easy updates:

```bash
#!/bin/bash
# deploy.sh - Deploy website to S3

set -e

BUCKET_NAME="awsopenclaw.com"
AWS_REGION="us-east-1"
DISTRIBUTION_ID="E1234567890ABC"  # Your CloudFront distribution ID

echo "🚀 Deploying to S3..."

# Upload files
aws s3 sync . s3://$BUCKET_NAME \
  --exclude ".git/*" \
  --exclude "*.md" \
  --exclude ".gitignore" \
  --exclude "deploy.sh" \
  --cache-control "max-age=3600" \
  --delete

echo "✅ Uploaded to S3"

# Invalidate CloudFront cache
if [ ! -z "$DISTRIBUTION_ID" ]; then
  echo "🔄 Invalidating CloudFront cache..."
  aws cloudfront create-invalidation \
    --distribution-id $DISTRIBUTION_ID \
    --paths "/*"
  echo "✅ Cache invalidated"
fi

echo "🎉 Deployment complete!"
echo "🌐 Site: https://awsopenclaw.com"
```

Make it executable:
```bash
chmod +x deploy.sh
./deploy.sh
```

---

## Troubleshooting

### Issue: CNAME not allowed for root domain

**Solution:**
- Use Route 53 for DNS management (supports ALIAS)
- Or use CloudFront with Route 53
- Or use www subdomain only

### Issue: SSL certificate not validating

**Solution:**
- Ensure DNS records are added correctly in GoDaddy
- Wait 30 minutes for propagation
- Check ACM console for validation status

### Issue: 403 Forbidden

**Solution:**
- Check bucket policy allows public read
- Verify static website hosting is enabled
- Check CloudFront origin settings

### Issue: Files not updating

**Solution:**
- Clear CloudFront cache (create invalidation)
- Check S3 sync command ran successfully
- Verify file permissions in S3

### Issue: HTTPS not working

**Solution:**
- Ensure CloudFront distribution is deployed
- Verify SSL certificate is attached
- Check CNAME points to CloudFront domain

---

## Cost Estimate

**S3:**
- Storage: ~$0.023/GB/month (negligible for static site)
- Requests: ~$0.0004 per 1,000 requests

**CloudFront:**
- Data transfer: ~$0.085/GB (first 10TB)
- Requests: ~$0.0075 per 10,000 HTTPS requests

**Total:** ~$0-5/month for typical traffic

---

## Quick Reference

```bash
# Upload files
aws s3 sync . s3://awsopenclaw.com --exclude ".git/*" --exclude "*.md"

# Invalidate CloudFront
aws cloudfront create-invalidation --distribution-id E1234567890ABC --paths "/*"

# Check bucket policy
aws s3api get-bucket-policy --bucket awsopenclaw.com

# Get CloudFront distribution
aws cloudfront list-distributions --query "DistributionList.Items[?Aliases.Items[?contains(@, 'awsopenclaw.com')]]"
```

---

## Next Steps

1. ✅ S3 bucket created and configured
2. ✅ Website files uploaded
3. ✅ CloudFront distribution created
4. ✅ SSL certificate issued
5. ✅ CNAME configured in GoDaddy
6. ⏳ Wait for DNS propagation (24-48 hours)
7. ✅ Test https://awsopenclaw.com

---

## Support

- AWS S3 Docs: https://docs.aws.amazon.com/s3/
- CloudFront Docs: https://docs.aws.amazon.com/cloudfront/
- GoDaddy DNS Help: https://www.godaddy.com/help

