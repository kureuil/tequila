FROM elixir:1.9.0-alpine as build

RUN apk add --update git build-base nodejs npm python

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# build assets
COPY assets assets
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

# build project
COPY priv priv
COPY lib lib
RUN mix compile

# build release
COPY rel rel
RUN mix release

# prepare release image
# cannot use the latest alpine version, something related to dlsym appears to be incompatible
FROM alpine:3.9 AS app
RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

COPY --from=build /app/_build/prod/rel/tequila ./
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app
