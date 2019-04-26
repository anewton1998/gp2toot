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

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--config', '-c', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--delete-posts', '-P', GetoptLong::NO_ARGUMENT ]
)

action = :post

opts.each do |opt, arg|
  case opt
  when '--help'
    puts "usage: gp2toot [--config=s]"
    exit 1
  when '--config'
    d = File.dirname( arg )
    if d == '.'
      require arg
    else
      require my_etc + '/' + arg
    end
  when '--delete-posts'
    action = :deletePosts
  else
    puts "error: unexpected input, try --help"
    exit 1
  end
end

Gp2Toot::Gp2Toot.new( Gp2Toot.configuration ).run( action )

