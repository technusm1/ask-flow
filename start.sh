#!/bin/bash

# Set environment variables for LM Studio
# Default port for LM Studio is 1234, adjust as needed
export OPENAI_API_URL="http://localhost:1234/v1"
export OPENAI_API_KEY="dummy-api-key"

echo "Starting Stack Overflow Clone with LM Studio integration"
echo "Make sure LM Studio is running on http://localhost:1234"
echo "and you have loaded a model in LM Studio"

# Start the Phoenix server
mix phx.server 