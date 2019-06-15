# gp2toot

Reads a Google+ (G+) Takeout (Takeaway) downloaded archive and sends them to Mastodon.

## Status

Current Status: *Needs User Testing and Feedback*

I have added all the functionality I plan to add at this point, and I'm waiting on feedback.

## Changelog

* Initial code prototype.
* 0.5 functionality:
  * Currently posting textual status to Mastodon.
  * Can delete the posted statuses.
  * Also can limit the number of posts per run, so posts can be migrated over time (via a cron)
  * Has a throttle time because to be nice.
  * Will split posts and thread them if they exceed the Mastodon status character limit
  * Uploads media associated with a post.
  * Removes HTML from the original G+ posts.
  * Will backdate posts if/when Mastodon adds the feature. See https://github.com/tootsuite/mastodon/issues/10639

## Prerequisites

You'll need
1. Ruby
2. Nokogiri
3. bundler

### Ruby
You'll need Ruby. This is being tested with version 2.6.2 so that is recommended at the very least. Installation varies depending on the system you are using.

### Nokogiri
Nokogiri is a Ruby extension that parse HTML and HTML fragments. It uses a native libxml extension to Ruby, so there may be extra steps required to install it. See https://nokogiri.org/tutorials/installing_nokogiri.html

### Bundler
Bundler is gem dependency manager for Ruby gems. Installing it is easy:

~~~
gem install bundler
~~~

## Install

After you have cloned this Git repository, run bundler to install all the necessary gem dependencies.

~~~
bundler install
~~~

## How to Use

In the `/etc` directory, there is a `sample_config.rb` file. Copy the file to a name of your desire (e.g. `my_config.rb`) and edit it with your parameters.

You can run an analysis on your G+ Takeout by doing the following:

~~~
bundler exec bin/gp2toot.rb -c my_config.rb -a
~~~

To get the access token (bearer token), you should go into your Mastodon settings -> development. Once there, create a new application. Once created, view it and get the access token.

Chances are that you will want to do a little testing before adding all your content. Use the `config.limit` value to limit the number of posts and media. Additionally, `config.visibility` should be left to `unlisted` for testing so that your posts don't annoy other users on the Mastodon instance.

The `config.throttle` value is important as Mastodon will start throttling you. Dropping it to zero is a surefire way of causing problems.

To migrate the G+ posts, execute with bundler like so:

~~~
bundler exec bin/gp2toot.rb -c my_config.rb -p
~~~

Be default, a log file is kept in `var` and along with files containing the status IDs of statuses that have been submitted.

To have the program attempt to delete its posts, you can pass the `--delete-posts` or `-P` option.

~~~
bundler exec bin/gp2toot.rb -c my_config.rb --delete-posts
~~~

By default, it will attempt to delete the posts from the last run. If you want it to delete all posts from all previous runs, use the `all` argument.

~~~
bundler exec bin/gp2toot.rb -c my_config.rb --delete-posts=all
~~~

To add posts over time, use the `config.limit` value, and simply run the program periodically (such as with cron). Gp2Toot keeps track of which G+ posts have been sent to Mastodon and will not resend posts.

## How to Provide Feedback

The best way to provide feedback is by entering a GitHub issue.

You can also contact me on Mastodon at [@rcode3@masto.rootdc.xyz](https://masto.rootdc.xyz/@rcode3).

## How to Contribute

If you want to provide bug fixes or new features or whatnot, please submit a Pull Request.