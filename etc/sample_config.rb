# Copyright (C) 2019 Andrew Newton
Gp2Toot.configure do |config|

  # file in var directory to write
  config.loggerOut = 'gp2toot.out'

  # to send to STDOUT
  #config.loggerOut = 'console'

  # values are 'warn', 'info', and 'debug'
  config.loggerLevel = 'debug'

  # the access token
  config.bearerToken = '8800b44816efe3aba9ed232264b42b0c832f3c70ae7146e03aba271db40e61f7'

  # the account name
  config.acct = 'test_gp2toot'

  # the URL of the Mastodon Instance
  config.baseUrl = 'https://masto.rootdc.xyz'

  # directory containing the takeout dump
  config.takeoutDir = '/home/andy/tmp/Takeout'

  # Either "direct", "private", "unlisted" or "public"
  config.visibility = 'unlisted'

  # time format appended to post text
  # for details on the format see
  # https://ruby-doc.org/stdlib-2.3.1/libdoc/date/rdoc/Date.html#method-i-strftime
  config.timeFormat = "[ originally posted on G+ on %b %-d, %Y, %k:%M ]"

  # limits the number of status and media to upload
  # this is useful for testing as you don't want to be deleting large numbers of
  # status and media
  # comment this out when it is time to do it for real
  config.limit = 2

  # throttle in seconds
  # play nice with the instance... this specifies the number of seconds to wait before
  # making another request
  #config.throttle = 2

  # The maximum length of a Mastodon status. The default for most instances is 500 characters.
  # However, some instances have higher limits. You'll need to check with the instance operator.
  #config.maxLength = 500

end
