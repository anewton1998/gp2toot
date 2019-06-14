# Copyright (C) 2019 Andrew Newton

require 'spec_helper'
require_relative '../lib/gp2toot'

describe 'content handling' do

    it 'should not split content that is not over the max content length' do
        config = Gp2Toot::Configuration.new
        config.maxLength = 10
        gp2toot = Gp2Toot::Main.new( config )
        c = gp2toot.splitPostContent( "123456789" )
        expect( c.size ).to eq( 1 )
        expect( c[0] ).to eq( "123456789" )
    end

    it 'should not split content that is the max content length' do
        config = Gp2Toot::Configuration.new
        config.maxLength = 10
        gp2toot = Gp2Toot::Main.new( config )
        c = gp2toot.splitPostContent( "1234567890" )
        expect( c.size ).to eq( 1 )
        expect( c[0] ).to eq( "1234567890" )
    end

    it 'should spit without whitespace and period' do
        config = Gp2Toot::Configuration.new
        config.maxLength = 10
        gp2toot = Gp2Toot::Main.new( config )
        c = gp2toot.splitPostContent( "1234567890123" )
        expect( c.size ).to eq( 7 )
        expect( c[0] ).to eq( "12 (1/7)" )
        expect( c[1] ).to eq( "34 (2/7)" )
        expect( c[5] ).to eq( "12 (6/7)" )
        expect( c[6] ).to eq( "3 (7/7)" )
    end

    it 'should spit with whitespace' do
        config = Gp2Toot::Configuration.new
        config.maxLength = 20
        gp2toot = Gp2Toot::Main.new( config )
        c = gp2toot.splitPostContent( "12 34 56 78 90 12 34 56 78" )
        expect( c.size ).to eq( 3 )
        expect( c[0] ).to eq( "12 34 56 78 (1/3)" )
        expect( c[1] ).to eq( "90 12 34 56 (2/3)" )
        expect( c[2] ).to eq( "78 (3/3)" )
    end

    it 'should spit with period' do
        config = Gp2Toot::Configuration.new
        config.maxLength = 20
        gp2toot = Gp2Toot::Main.new( config )
        c = gp2toot.splitPostContent( "12 34 56 78.90 12 34 56.78" )
        expect( c.size ).to eq( 3 )
        expect( c[0] ).to eq( "12 34 56 78. (1/3)" )
        expect( c[1] ).to eq( "90 12 34 56. (2/3)" )
        expect( c[2] ).to eq( "78 (3/3)" )
    end

end

