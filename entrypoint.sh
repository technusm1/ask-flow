#!/bin/sh

# Exit on failure
set -e

echo "Running database migrations..."
bin/ask_flow eval "AskFlow.Release.migrate"

echo "Starting application..."
exec bin/ask_flow start
