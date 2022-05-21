# latest_blank_rails_project
RubyもRailsも最新安定バージョンになっている、中身がないRailsプロジェクト
The blank project which uses latest stable versions of Ruby and Rails.

# The options when run `bundle exec rails new`

```sh
bundle exec rails new latest_blank_rails_project \
  --database=postgresql \
  --skip-test
```

## SETUP

```
echo 'db96175e496781b9fb7ebd6701ada024' > app/config/master.key
docker compose run --rm app bin/rails db:create
```


## RUN

### When run on port 3000

```
docker compose up
```

### When run on other ports

```
PORT=13000 docker compose up
```
