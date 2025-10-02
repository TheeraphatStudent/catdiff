#!/bin/bash

# Script to remove Cloud SQL from Google Cloud Project
# Project: catdiff-9db92

set -e

PROJECT_ID="lottocat"
REGION="us-south1-b"

echo "========================================="
echo "Cloud SQL Removal Script"
echo "Project: $PROJECT_ID"
echo "========================================="
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud CLI is not installed"
    echo "Install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Set the project
echo "📋 Setting project to: $PROJECT_ID"
gcloud config set project "$PROJECT_ID"
echo ""

# List all Cloud SQL instances
echo "🔍 Listing all Cloud SQL instances in project..."
echo "-------------------------------------------"
INSTANCES=$(gcloud sql instances list --format="value(name)" 2>/dev/null || echo "")

if [ -z "$INSTANCES" ]; then
    echo "✅ No Cloud SQL instances found in project $PROJECT_ID"
    echo ""
    echo "Your project is already clean!"
    exit 0
fi

echo "Found the following Cloud SQL instances:"
echo "$INSTANCES"
echo ""

# Show instance details
echo "📊 Instance Details:"
echo "-------------------------------------------"
gcloud sql instances list --format="table(name,region,databaseVersion,state,tier)"
echo ""

# Confirm deletion
read -p "⚠️  Do you want to DELETE all Cloud SQL instances? This action CANNOT be undone! (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Deletion cancelled"
    exit 0
fi

# Delete each instance
echo ""
echo "🗑️  Deleting Cloud SQL instances..."
echo "-------------------------------------------"

for INSTANCE_NAME in $INSTANCES; do
    echo "Deleting instance: $INSTANCE_NAME"
    
    # Delete the instance (this will also delete backups)
    gcloud sql instances delete "$INSTANCE_NAME" --quiet
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully deleted: $INSTANCE_NAME"
    else
        echo "❌ Failed to delete: $INSTANCE_NAME"
    fi
    echo ""
done

echo "========================================="
echo "✅ Cloud SQL Removal Complete!"
echo "========================================="
echo ""

# Check for any remaining SQL-related resources
echo "🔍 Checking for remaining SQL-related resources..."
echo ""

# Check for SQL backups
echo "Checking for SQL backups..."
BACKUPS=$(gcloud sql backups list --instance="" 2>/dev/null || echo "")
if [ -z "$BACKUPS" ]; then
    echo "✅ No SQL backups found"
else
    echo "⚠️  Found SQL backups (these should be auto-deleted with instances)"
fi

echo ""
echo "📝 Next Steps:"
echo "1. Update your application to use a different database (local PostgreSQL, etc.)"
echo "2. Remove Cloud SQL connection strings from your .env files"
echo "3. Update your backend configuration to point to the new database"
echo ""
