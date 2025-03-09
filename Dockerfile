# 1️⃣ Base stage - Common dependencies
FROM elixir AS base
RUN apt update && apt install -y build-essential npm git curl postgresql-client
WORKDIR /app
COPY mix.exs mix.lock ./
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get && mix deps.compile
# Force compile bcrypt_elixir
RUN mix deps.compile bcrypt_elixir --force

# 2️⃣ Build stage - Only for production
FROM base AS build
ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}
COPY config config
COPY priv priv
COPY lib lib
COPY assets assets
RUN if [ "$MIX_ENV" = "prod" ]; then mix assets.deploy; fi
RUN mix compile
RUN if [ "$MIX_ENV" = "prod" ]; then mix release --path /app/release; fi

# 3️⃣ Production runtime image
FROM elixir AS prod
RUN apt update && apt install -y bash openssl postgresql-client
WORKDIR /app
COPY --from=build /app/release ./
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
CMD ["./entrypoint.sh"]

# 4️⃣ Development runtime image
FROM base AS dev
ARG MIX_ENV=dev
ENV MIX_ENV=${MIX_ENV}
CMD ["mix", "phx.server"]
