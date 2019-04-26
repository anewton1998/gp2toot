Gp2Toot.configure do |config|

  # file in var directory to write
  config.loggerOut = 'gp2toot.out'

  # to send to STDOUT
  #config.loggerOut = 'console'

  # values are 'warn', 'info', and 'debug'
  config.loggerLevel = 'debug'

  # the access token
  config.bearerToken = '9adb636d6343322795e10fa4411dd68fcd08d7088989b1e5bd3a7e47eac59ee1'

  # the account name
  config.acct = 'botsington_sr'

  # the URL of the Mastodon Instance
  config.baseUrl = 'http://masto.rootdc.xyz'

  # directory containing the takeout dump
  config.takeoutDir = '/home/andy/tmp/Takeout'

end
