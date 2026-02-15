# DNS Records Fix for awsopenclaw.com

## Current Issue

Your `www` CNAME record is pointing to `awsopenclaw.com.` which creates a DNS loop. It should point to your CloudFront distribution.

## Required DNS Records

### ✅ Keep These (SSL Validation - Already Correct)

**Record 1: SSL Validation for Root Domain**
```
Type: CNAME
Name: _862c038ef6eafa9dabeeec0ba1c31507.awsopenclaw.com
Value: _f0e53e131f093394b1f063e032f3ccb1.jkddzztszm.acm-validations.aws.
TTL: 1 Hour
```

**Record 2: SSL Validation for www**
```
Type: CNAME
Name: _a6f98b6c5fa4331832d3e4859742bfe9.www.awsopenclaw.com
Value: _9d99c0fb9795c6f9a935a1955c5ff38d.jkddzztszm.acm-validations.aws.
TTL: 1 Hour
```

### ❌ Fix This (Website CNAME)

**Current (WRONG):**
```
Type: CNAME
Name: www
Value: awsopenclaw.com.  ← This creates a DNS loop!
```

**Should Be:**
```
Type: CNAME
Name: www
Value: d2aafktu3u7wab.cloudfront.net
TTL: 1 Hour
```

### ➕ Add This (Root Domain - Optional)

**If GoDaddy Allows CNAME for Root Domain:**
```
Type: CNAME (or ALIAS)
Name: @
Value: d2aafktu3u7wab.cloudfront.net
TTL: 1 Hour
```

**Note:** If GoDaddy doesn't support CNAME for `@`, you can:
- Use `www` subdomain only, or
- Transfer DNS to AWS Route 53 (supports ALIAS for root domains)

## Steps to Fix

1. **Log in to GoDaddy**
   - Go to https://www.godaddy.com
   - Navigate to DNS settings for `awsopenclaw.com`

2. **Edit the www CNAME Record**
   - Find the record: `www → awsopenclaw.com.`
   - Click Edit
   - Change Value to: `d2aafktu3u7wab.cloudfront.net`
   - Remove trailing dot (.)
   - Save

3. **Add Root Domain CNAME (Optional)**
   - Click "Add Record"
   - Type: CNAME
   - Name: `@`
   - Value: `d2aafktu3u7wab.cloudfront.net`
   - TTL: 1 Hour
   - Save

4. **Verify Records**
   Your DNS should have:
   - ✅ SSL validation records (2 records)
   - ✅ www → d2aafktu3u7wab.cloudfront.net
   - ✅ @ → d2aafktu3u7wab.cloudfront.net (if supported)

## After Fixing

- **Wait 5-30 minutes** for DNS propagation
- Test: `https://www.awsopenclaw.com`
- Test: `https://awsopenclaw.com` (if root domain CNAME added)

## Verify DNS

Check DNS propagation:
- https://www.whatsmydns.net/#CNAME/www.awsopenclaw.com
- https://www.whatsmydns.net/#CNAME/awsopenclaw.com

Both should resolve to `d2aafktu3u7wab.cloudfront.net`

## Troubleshooting

**If www still doesn't work:**
- Wait longer (DNS can take 24-48 hours)
- Clear browser cache
- Try incognito/private mode
- Check DNS with: `dig www.awsopenclaw.com`

**If root domain doesn't work:**
- GoDaddy may not support CNAME for `@`
- Use Route 53 for DNS (supports ALIAS)
- Or use `www` subdomain only

