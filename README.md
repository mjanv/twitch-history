# Twitch Story

## About

> Twitch Story is a web application targeting Twitch viewers. It enables them to ...

Current beta version of the application is available at [https://twitch-story.fly.dev/](https://twitch-story.fly.dev/). Data and account integrity are not guarranted. Known beta-testers: damienscaletta, babiilabilux.

- Error tracking: https://maxime-janvier.sentry.io/projects
- Data storage: https://console.tigris.dev/flyio_6x3wkn12kqwmqvop/buckets

## Installation

With [asdf](https://asdf-vm.com/) installed,

```bash
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir
asdf install
```

The application is using Twitch APIs and Oauth authentification system. To be able to connect, an application should be created in [Twitch Developers](https://dev.twitch.tv/console) to get a client id and secret. The following environment variables shoud be available in a `.env` file:

```bash
TWITCH_CLIENT_ID=<client_id>
TWITCH_CLIENT_SECRET=<client_secret>
TWITCH_REDIRECT_URI=http://localhost:4000/auth/twitch/callback
```

```bash
export $(cat .env)
```

## Local development

Application can be runned locally using:

```bash
docker compose up -d
mix
```

To run code quality assurance:

```bash
mix quality
```

To run unit tests:

```bash
docker compose up -d
mix test # or mix test.unit
mix test.integration
```

All tests implying real Twitch API calls are, by default, excluded from unit test and only avaible in integration tests.

## Deployment

The application is deployed ont [Fly.io](https://fly.io/) with . All 

To build the docker image, run

```bash
mix deploy.build
```

Error tracking is available at [Sentry](https://maxime-janvier.sentry.io/projects/) through Fly.io integration. `SENTRY_DSN` environment variable should be set to enable it.

Data buckets (`twitch-story-data`) are available at [Tigris](https://console.tigris.dev/flyio_6x3wkn12kqwmqvop/buckets) through Fly.io integration.

## Ressources

- https://aurmartin.fr/posts/phoenix-liveview-select/
