#!/bin/bash
# deploy.sh - Deploy OpenClaw on AWS website to S3

set -e

# Configuration
BUCKET_NAME="awsopenclaw.com"
AWS_REGION="us-east-1"
DISTRIBUTION_ID=""  # Set your CloudFront distribution ID here

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Deploying OpenClaw on AWS website to S3...${NC}\n"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${YELLOW}❌ AWS CLI not found. Please install it first.${NC}"
    exit 1
fi

# Check if bucket exists
if ! aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
    echo -e "${GREEN}✅ Bucket $BUCKET_NAME exists${NC}"
else
    echo -e "${YELLOW}⚠️  Bucket $BUCKET_NAME does not exist. Creating...${NC}"
    aws s3 mb "s3://$BUCKET_NAME" --region "$AWS_REGION"
    echo -e "${GREEN}✅ Bucket created${NC}"
fi

# Upload files
echo -e "\n${BLUE}📤 Uploading files to S3...${NC}"
aws s3 sync . "s3://$BUCKET_NAME" \
  --exclude ".git/*" \
  --exclude "*.md" \
  --exclude ".gitignore" \
  --exclude "deploy.sh" \
  --exclude "DEPLOYMENT.md" \
  --exclude "S3_DEPLOYMENT.md" \
  --exclude "QUICK_DEPLOY.md" \
  --cache-control "max-age=3600" \
  --delete \
  --region "$AWS_REGION"

echo -e "${GREEN}✅ Files uploaded to S3${NC}"

# Invalidate CloudFront cache if distribution ID is set
if [ ! -z "$DISTRIBUTION_ID" ]; then
    echo -e "\n${BLUE}🔄 Invalidating CloudFront cache...${NC}"
    INVALIDATION_ID=$(aws cloudfront create-invalidation \
      --distribution-id "$DISTRIBUTION_ID" \
      --paths "/*" \
      --query 'Invalidation.Id' \
      --output text)
    
    echo -e "${GREEN}✅ Cache invalidation created: $INVALIDATION_ID${NC}"
    echo -e "${YELLOW}⏳ Cache invalidation takes 1-5 minutes to complete${NC}"
else
    echo -e "\n${YELLOW}ℹ️  CloudFront distribution ID not set. Skipping cache invalidation.${NC}"
    echo -e "${YELLOW}   Set DISTRIBUTION_ID in this script to enable cache invalidation.${NC}"
fi

echo -e "\n${GREEN}🎉 Deployment complete!${NC}"
echo -e "${BLUE}🌐 Site: https://awsopenclaw.com${NC}"
echo -e "${BLUE}📊 S3 Console: https://s3.console.aws.amazon.com/s3/buckets/$BUCKET_NAME${NC}"

