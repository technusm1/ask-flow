FROM elixir:1.14-alpine AS build

# Install build dependencies
RUN apk add --no-cache build-base npm git python3

WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV=prod

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Copy config files
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# Copy assets
COPY assets assets
COPY priv priv

# Compile assets
RUN mix assets.deploy

# Copy the rest of the application
COPY lib lib

# Compile the application
RUN mix compile

# Generate the release
RUN mix release

# Start a new build stage
FROM alpine:3.16 AS app

RUN apk add --no-cache openssl ncurses-libs libstdc++

WORKDIR /app

# Copy the release from the build stage
COPY --from=build /app/_build/prod/rel/ask_flow ./

# Set environment variables
ENV HOME=/app
ENV PORT=4000
ENV PHX_HOST=localhost
ENV DATABASE_URL=ecto://postgres:postgres@db/ask_flow_prod
ENV SECRET_KEY_BASE=your_secret_key_base_here

# Expose the port
EXPOSE 4000

# Start the application
CMD ["bin/ask_flow", "start"] 