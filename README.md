# gp2toot

Reads a Google+ (G+) Takeout (Takeaway) downloaded archive and sends them to Mastodon.

## Status

Current functionality

* Currently posting textual status to Mastodon.
* Can delete the posted statuses.
* Also can limit the number of posts for testing purposes.
* Has a throttle time because to be nice.
* Will split posts and thread them if they exceed the Mastodon status character limit

Needs to do

* Dealing with HTML content
* Dealing with media (photos) comes next
* Find a way to actually backdate posts. See https://github.com/tootsuite/mastodon/issues/10639
* Test with posts with no content

*I NEED YOUR HELP* The Takeout corpus I have does not have any correlated G+ posts with G+ photos. If you have information on how this information is related, I would be very grateful to be informed.

## Changelog

* Hopefully added more graceful throttling.
* Added --delete-posts=last and --delete-posts=all logic

## Prerequisites

You'll need Ruby. This is being tested with version 2.6.2 so that is recommended at the very least.

Also, you'll need Ruby bundler to install Ruby dependencies and run the program.

~~~
gem install bundler
~~~

Once that is installed, have bundler go grab the necessary dependencies:

~~~
bundler install
~~~

## How to Use

In the `/etc` directory, there is a `sample_config.rb` file. Copy the file to a name of your desire (e.g. `my_config.rb`) and edit it with your parameters.

To get the access token (bearer token), you should go into your Mastodon settings -> development. Once there, create a new application. Once created, view it and get the access token.

Chances are that you will want to do a little testing before adding all your content. Use the `config.limit` value to limit the number of posts and media. Additionally, `config.visibility` should be left to `unlisted` for testing so that your posts don't annoy other users on the Mastodon instance.

The `config.throttle` value is important as Mastodon will start throttling you. Dropping it to zero is a surefire way of causing problems.

To migrate the G+ posts, execute with bundler like so:

~~~
bundler exec bin/gp2toot.rb -c test_config.rb -p
~~~

Be default, a log file is kept in `var` and along with files containing the post IDs of posts that have been submitted.

To have the program attempt to delete its posts, you can pass the `--delete-posts` option.

~~~
bundler exec bin/gp2toot.rb -c test_config.rb --delete-posts
~~~

By default, it will attempt to delete the posts from the last run. If you want it to delete all posts from all previous runs, use the `all` argument.

~~~
bundler exec bin/gp2toot.rb -c test_config.rb --delete-posts=all
~~~

## How to Provide Feedback

The best way to provide feedback is by entering a GitHub issue.

You can also contact me on Mastodon at [@rcode3@masto.rootdc.xyz](https://masto.rootdc.xyz/@rcode3).

## How to Contribute

If you want to provide bug fixes or new features or whatnot, please submit a Pull Request.
kkkk