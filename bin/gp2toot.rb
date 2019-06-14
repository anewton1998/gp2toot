#!/usr/bin/env ruby
#
# == Synopsis
#
# gp2toot - G+ to Mastodon converter.
#
# == Usage
#
# gp2toot [options]
#
# -h, --help:
#    show help
#
# -c f, --config f:
#    configuration file

# Copyright (C) 2019 Andrew Newton

my_bin    = File.dirname(__FILE__)
my_lib    = my_bin + '/../lib'
my_etc    = my_bin + '/../etc'

$: << my_lib
$: << my_etc

require 'gp2toot'
require 'getoptlong'

USAGE = <<EOF
usage: gp2toot OPTIONS

  where OPTIONS are:

  -c or --config       Specifies the configuration file (REQUIRED).

  plus one action argument:

  -h or --help         Prints this help and exits.
  -p or --post         Posts statuses.
  -P or --delete-posts Deletes posts. Optional arguments:
                         =all to delete all posts
                         =last to delete posts from last run
  -a or --analyze      Analyze Takeout posts.

EOF

opts = GetoptLong.new(
  [ '--config', '-c', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--post', '-p', GetoptLong::NO_ARGUMENT ],
  [ '--analyze', '-a', GetoptLong::NO_ARGUMENT ],
  [ '--delete-posts', '-P', GetoptLong::OPTIONAL_ARGUMENT ]
)

action = nil
params = {}

opts.each do |opt, arg|
  if action
    puts( "More than one action option given" )
    exit( 1 )
  end

  case opt
  when '--help'
    puts( USAGE )
    exit( 1 )
  when '--config'
    d = File.dirname( arg )
    if d == '.'
      require arg
    else
      require my_etc + '/' + arg
    end
  when '--delete-posts'
    action = :deletePosts
    case arg
    when ''
      params[ :deletePosts ] = :last
    when 'all'
      params[ :deletePosts ] = :all
    when 'last'
      params[ :deletePosts ] = :last
    else
      raise ArgumentError( "--delete-posts argument #{arg} is not understood" )
    end
  when '--post'
    action = :post
  when '--analyze'
    action = :analyze
  else
    puts( "error: unexpected input, try --help" )
    exit( 1 )
  end
end

unless action
  puts( "No action option given" )
  exit( 1 )
end

Gp2Toot::Main.new( Gp2Toot.configuration ).run( action, params )
