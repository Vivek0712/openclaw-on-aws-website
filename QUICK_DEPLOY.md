# Quick Deploy to awsopenclaw.com

## 🚀 Fastest Method: GitHub Pages (5 minutes)

### Step 1: Enable GitHub Pages
1. Visit: https://github.com/Vivek0712/openclaw-on-aws-website/settings/pages
2. Under **Source**, select:
   - Branch: `main`
   - Folder: `/ (root)`
3. Click **Save**

### Step 2: Add Custom Domain
1. In the same Pages settings, scroll to **Custom domain**
2. Enter: `awsopenclaw.com`
3. Check **Enforce HTTPS**
4. Click **Save**

### Step 3: Update GoDaddy DNS
1. Log in to GoDaddy: https://www.godaddy.com
2. Go to **My Products** → Find `awsopenclaw.com` → **DNS**
3. Add these **A records** (replace existing if any):

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

4. Add **CNAME** for www:

```
Type: CNAME
Name: www
Value: vivek0712.github.io
TTL: 600
```

5. **Save** all changes

### Step 4: Wait & Verify
- DNS propagation: 24-48 hours
- Check status: https://www.whatsmydns.net/#A/awsopenclaw.com
- Once green, your site will be live at https://awsopenclaw.com

---

## ✅ That's it!

Your site will automatically deploy on every push to the `main` branch.

**Temporary URL** (works immediately):
- https://vivek0712.github.io/openclaw-on-aws-website/

**Custom Domain** (after DNS propagates):
- https://awsopenclaw.com
- https://www.awsopenclaw.com

