# DNS Setup Instructions for awsopenclaw.com

## ✅ What's Already Done

- ✅ S3 bucket created and website deployed
- ✅ SSL certificate requested in ACM (us-east-1)
- ✅ CloudFront distribution created
- ⏳ Waiting for SSL certificate validation
- ⏳ Waiting for CloudFront custom domain configuration

---

## 📋 Step 1: Add SSL Certificate Validation Records

**Go to GoDaddy DNS Settings:**
1. Log in to https://www.godaddy.com
2. Go to **My Products** → Find `awsopenclaw.com` → **DNS**
3. Add these **TWO CNAME records** for SSL validation:

### Record 1 (for awsopenclaw.com):
```
Type: CNAME
Name: _862c038ef6eafa9dabeeec0ba1c31507.awsopenclaw.com
Value: _f0e53e131f093394b1f063e032f3ccb1.jkddzztszm.acm-validations.aws.
TTL: 600 seconds
```

**⚠️ Important:** When entering in GoDaddy, if it asks:
- "Do you want this to resolve on _862c038ef6eafa9dabeeec0ba1c31507.awsopenclaw.com instead?"
- Select **"Yes"** - This prevents duplicate domain (awsopenclaw.com.awsopenclaw.com)

### Record 2 (for www.awsopenclaw.com):
```
Type: CNAME
Name: _a6f98b6c5fa4331832d3e4859742bfe9.www.awsopenclaw.com
Value: _9d99c0fb9795c6f9a935a1955c5ff38d.jkddzztszm.acm-validations.aws.
TTL: 600 seconds
```

**⚠️ Important:** Same for this record - if GoDaddy asks about the name, select **"Yes"** to use the correct subdomain.

4. **Save** all changes

**Wait 5-30 minutes** for AWS to validate the certificate. Check status:
- https://console.aws.amazon.com/acm/home?region=us-east-1#/certificates/arn:aws:acm:us-east-1:666712642894:certificate/6c6bf804-5a18-4a7d-98d5-20b505c09a21

---

## 📋 Step 2: Configure CloudFront Custom Domain (After SSL Validated)

Once the SSL certificate status changes to **"Issued"**:

1. Go to CloudFront Console:
   https://console.aws.amazon.com/cloudfront/v3/home#/distributions/E3D0B4X3JNA2YU

2. Click **Edit**

3. Under **Alternate domain names (CNAMEs)**:
   - Click **Add item**
   - Enter: `awsopenclaw.com`
   - Click **Add item** again
   - Enter: `www.awsopenclaw.com`

4. Under **Custom SSL certificate**:
   - Select: `arn:aws:acm:us-east-1:666712642894:certificate/6c6bf804-5a18-4a7d-98d5-20b505c09a21`
   - Or select from dropdown: The certificate for awsopenclaw.com

5. Click **Save changes**

6. Wait 5-15 minutes for CloudFront to deploy

---

## 📋 Step 3: Add Website CNAME in GoDaddy (After CloudFront Updated)

Once CloudFront distribution shows **"Deployed"** status:

1. Go back to GoDaddy DNS settings

2. Add **CNAME record** for website:

### For root domain (@):
```
Type: CNAME
Name: @
Value: d2aafktu3u7wab.cloudfront.net
TTL: 600 seconds
```

**Note:** If GoDaddy doesn't allow CNAME for `@`, you may need to:
- Use Route 53 for DNS (supports ALIAS)
- Or use `www` subdomain only

### For www subdomain:
```
Type: CNAME
Name: www
Value: d2aafktu3u7wab.cloudfront.net
TTL: 600 seconds
```

3. **Save** changes

---

## ⏳ Timeline

- **SSL Validation:** 5-30 minutes after DNS records added
- **CloudFront Deployment:** 5-15 minutes after configuration update
- **DNS Propagation:** 24-48 hours for full global propagation

---

## 🔗 Quick Links

- **ACM Certificate:** https://console.aws.amazon.com/acm/home?region=us-east-1#/certificates/arn:aws:acm:us-east-1:666712642894:certificate/6c6bf804-5a18-4a7d-98d5-20b505c09a21
- **CloudFront Distribution:** https://console.aws.amazon.com/cloudfront/v3/home#/distributions/E3D0B4X3JNA2YU
- **S3 Bucket:** https://s3.console.aws.amazon.com/s3/buckets/awsopenclaw.com
- **GoDaddy DNS:** https://www.godaddy.com

---

## ✅ Verification

After all steps complete, test:

- ✅ https://awsopenclaw.com (should load with HTTPS)
- ✅ https://www.awsopenclaw.com (should load with HTTPS)
- ✅ Check SSL certificate is valid
- ✅ All website features work

---

## 📊 Current Status

- **S3 Website:** ✅ Live at http://awsopenclaw.com.s3-website-us-east-1.amazonaws.com
- **SSL Certificate:** ⏳ PENDING_VALIDATION (add DNS records)
- **CloudFront:** ⏳ Deploying (E3D0B4X3JNA2YU)
- **Custom Domain:** ⏳ Waiting for SSL validation

---

## 🆘 Troubleshooting

**SSL not validating?**
- Check DNS records are added correctly
- Wait 30 minutes
- Verify CNAME records in GoDaddy match exactly (including trailing dot)

**CloudFront not accepting certificate?**
- Ensure certificate is in "Issued" status
- Certificate must be in us-east-1 region
- Wait for certificate to fully validate

**CNAME not working for root domain?**
- Some registrars don't support CNAME for `@`
- Consider using Route 53 (supports ALIAS)
- Or use www subdomain only

---

**Your site will be live at https://awsopenclaw.com once all steps are complete!** 🎉

