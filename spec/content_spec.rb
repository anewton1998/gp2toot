# Copyright (C) 2019 Andrew Newton

require 'spec_helper'
require_relative '../lib/gp2toot'

describe 'content handling' do

    it 'should not split content that is not over the max content length' do
        config = Gp2Toot::Configuration.new
        config.maxLength = 10
        gp2toot = Gp2Toot::Gp2Toot.new( config )
        c = gp2toot.splitPostContent( "123456789" )
        expect c.length == 9
    end

end

