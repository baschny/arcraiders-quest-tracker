#!/bin/bash
# Simple HTTP server for local development and testing
# Usage: ./serve.sh [port]

PORT=${1:-8080}

echo "Starting local web server..."
echo "Open http://localhost:$PORT in your browser"
echo "Press Ctrl+C to stop the server"
echo ""

# Use Python 3's built-in HTTP server
python3 -m http.server $PORT
