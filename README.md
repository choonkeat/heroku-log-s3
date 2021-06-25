# Heroku Log S3

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Configure

Setup the following `ENV` (aka `heroku config:set`)

- `FILTER_PREFIX` this is the prefix string to look out for. every other log lines are ignored
- `S3_KEY`, `S3_SECRET`, `S3_BUCKET` necessary ACL to your s3 bucket
- `AWS_REGION` the AWS region your S3 bucket is in
- `DURATION` (default `60`) seconds to buffer until we close the `IO` to `AWS::S3::S3Object#write`
- `STRFTIME` (default `%Y%m/%d/%H/%M%S.:thread_id.log`) format of your s3 `object_id`
  - `:thread_id` will be replaced by a unique number to prevent overwriting of the same file between reboots, in case the timestamp overlaps
- `HTTP_USER`, `HTTP_PASSWORD` (default no password protection) credentials for HTTP Basic Authentication
- `WRITER_LIB` (default `./writer/s3.rb`) defines the ruby script to load `Writer` class

## Using

In your heroku app, add this drain (changing `HTTP_USER`, `HTTP_PASSWORD` and `DRAIN_APP_NAME` to appropriate values)

```
heroku drains:add https://HTTP_USER:HTTP_PASSWORD@DRAIN_APP_NAME.herokuapp.com/
```

or if you have no password protection

```
heroku drains:add https://DRAIN_APP_NAME.herokuapp.com/
```

# Credits

- https://github.com/rwdaigle/heroku-log-parser
- https://github.com/rwdaigle/heroku-log-store

# Alternatives

- https://logbox.io a logs drain that forwards Heroku messages for a long‑term archival to AWS S3, Glacier or CloudWatch.
- _{insert suggestions here}_
