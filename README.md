# Notes
- Remember to create the databases first `ruby_api_development`, `ruby_api_test`
- Create `.env` file by copying the `.env.example` file and change the information of `DB_URL` and `TEST_DB_URL` to make it work properly.
- Run migration by these commands. This is the default one, might be slightly different in your side.
```bash
# Development
sequel -m db/migrate postgres://postgres:postgres@127.0.0.1:5432/ruby_api_development

# Test
sequel -m db/migrate postgres://postgres:postgres@127.0.0.1:5432/ruby_api_test
```
- Run seed `ruby db/seed.rb`
- Run server: `rackup`

Server will be running in port `1337` by default.
