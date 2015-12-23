# browserstack-screenshot-task

## Set up

```bash
# Install gems
bundle install
# update browsers
bundle exec rake screenshot:update_browsers
```

## Take screenshot

```bash
bundle exec rake screenshot:take[https://github.com/]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2015 Daisuke Taniwaki. See [LICENSE](LICENSE) for details.
