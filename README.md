SpreeVideoSupport
=================

SpreeVideoSupport video enhances your Spree Ecommerce site by providing instant video support feature. This feature allows customer to raise a ticket and can ask for video chat. Once a customer has initiated the request for video chat, admin will be able to respond to the request and start the chat.

This extension uses [temasys](https://www.temasys.io/) to provide video support.

Admins marked as support agent will be able to respond to video requests

Demo
----
Try Spree Video Support for Spree master with direct deployment on Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/vinsol-spree-contrib/spree-demo-heroku/tree/spree-video-support-master)

Try Spree Video Support for Spree 3-4 with direct deployment on Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/vinsol-spree-contrib/spree-demo-heroku/tree/spree-video-support-3-4)

Try Spree Video Support for Spree 3-1 with direct deployment on Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/vinsol-spree-contrib/spree-demo-heroku/tree/spree-video-support-3-1)

NOTE:Make sure you add Temasys API keys in Video Support Settings under Configuration from Admin section.

Installation
------------

Add spree_video_support to your Gemfile with this line:

  #### Spree >= 3.1

  ```ruby
  gem 'spree_video_support', github: 'vinsol-spree-contrib/spree-video-support'
  ```

  #### Spree < 3.1

  ```ruby
  gem 'spree_video_support', github: 'vinsol-spree-contrib/spree-video-support', branch: 'X-X-stable'
  ```

  The `branch` option is important: it must match the version of Spree you're using.
  For example, use `3-0-stable` if you're using Spree `3-0-stable` or any `3.0.x` version.

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_video_support:install
```

Usage
--------
* Get API keys from [temasys](https://www.temasys.io/).
* Add these keys 'Video Support Settings' page under Configuration section in Admin panel.
* To mark user as "support agent" go to the edit page of the user and give him "SUPPORT_AGENT" role.
* To reach the Support Interface, first log into your store with your support agent account, then go to the /support directory of your site.

Testing
-------

First bundle your dependencies, then run `rake`. `rake` will default to building the dummy app if it does not exist, then it will run specs. The dummy app can be regenerated by using `rake test_app`.

```shell
bundle
bundle exec rake
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_video_support/factories'
```

Credits
-------

[![vinsol.com: Ruby on Rails, iOS and Android developers](http://vinsol.com/vin_logo.png "Ruby on Rails, iOS and Android developers")](http://vinsol.com)

Copyright (c) 2016 [vinsol.com](http://vinsol.com "Ruby on Rails, iOS and Android developers"), released under the New MIT License
