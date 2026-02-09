# MyAnime (Ruby on Rails)

기존 `React + Spring Boot` 구성을 `Ruby + Ruby on Rails` 단일 앱으로 전환했습니다.

## Stack
- Ruby 4.0.0+ (latest stable line)
- Ruby on Rails 8.1.2
- SQLite (기본)

## API Endpoints
- `GET /api/health`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `GET /api/anime`
- `GET /api/anime/:id`
- `GET /api/anime/:id/like`
- `POST /api/anime/:id/like`
- `DELETE /api/anime/:id/like`
- `GET /api/anime/likes`
- `GET /api/news`
- `GET /api/quotes`
- `POST /api/admin/ingest/anilist/season`
- `POST /api/admin/ingest/animechan/quotes`
- `POST /api/admin/ingest/newsapi`
- `POST /api/admin/ingest/status`
- `POST /api/admin/ingest/all`

## Run
1. `.env.example`를 참고해 `.env` 생성
2. Ruby를 4.0.0 이상으로 업그레이드
3. `bundle install`
4. `bundle exec rails db:create db:migrate`
5. `./dev.sh`

기본 서버 포트는 `8082`입니다.

## Manual Ingestion
- `./ingest.sh`
