Gp2Toot.configure do |config|

  # file in var directory to write
  config.loggerOut = 'gp2toot.out'

  # to send to STDOUT
  #config.loggerOut = 'console'

  # values are 'warn', 'info', and 'debug'
  config.loggerLevel = 'debug'

  # the access token
  config.bearerToken = '7800b44816efe3aba9ed232264b42b0c832f3c70ae7146e03aba271db40e61f8'

  # the account name
  config.acct = 'gp2toot'

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

end
