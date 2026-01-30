#!/bin/bash
# Development runner script for macOS/Linux
# This script loads environment variables and runs the Flutter app

# Check if .env file exists
if [ ! -f .env ]; then
    echo "ERROR: .env file not found!"
    echo ""
    echo "Please create a .env file from .env.example:"
    echo "  1. Copy .env.example to .env"
    echo "  2. Fill in your Supabase credentials"
    echo ""
    exit 1
fi

# Load environment variables from .env file
export $(cat .env | grep -v '^#' | xargs)

# Check if required variables are set
if [ -z "$SUPABASE_URL" ]; then
    echo "ERROR: SUPABASE_URL not set in .env file"
    exit 1
fi

if [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "ERROR: SUPABASE_ANON_KEY not set in .env file"
    exit 1
fi

# Run Flutter with dart-define
echo "Running Flutter app with Supabase configuration..."
echo ""
flutter run \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
