#!/bin/bash

# Load all environment variables from .env
export $(grep -v '^#' .env | xargs)

# Start the Phoenix server
mix phx.server 