# Copyright (C) 2019 Andrew Newton

require 'spec_helper'
require_relative '../lib/gp2toot'

describe 'transform G+ content' do

    it 'should filter all content' do
        gpp = Gp2Toot::GplusPost.new
        gpp.content = "foo<br>thingy"
        gpp.linkUrl = "http://example.com"
        gpp.mediaUrl = "http://example.net"
        format = "[ on G+ %b %-d, %Y, %k:%M ]"
        gpp.creationTime = "2019-01-13T22:30:33-0500"
        content = Gp2Toot.transformContent( gpp, format )
        expect( content ).to eq( "foo\nthingy\n\nhttp://example.com\n\nhttp://example.net\n\n[ on G+ Jan 13, 2019, 22:30 ]" )
    end

    it 'should filter no link' do
        gpp = Gp2Toot::GplusPost.new
        gpp.content = "foo<br>thingy"
        format = "[ on G+ %b %-d, %Y, %k:%M ]"
        gpp.creationTime = "2019-01-13T22:30:33-0500"
        content = Gp2Toot.transformContent( gpp, format )
        expect( content ).to eq( "foo\nthingy\n\n[ on G+ Jan 13, 2019, 22:30 ]" )
    end

    it 'should filter blank format' do
        gpp = Gp2Toot::GplusPost.new
        gpp.content = "foo<br>thingy"
        gpp.linkUrl = "http://example.com"
        format = ""
        gpp.creationTime = "2019-01-13T22:30:33-0500"
        content = Gp2Toot.transformContent( gpp, format )
        expect( content ).to eq( "foo\nthingy\n\nhttp://example.com" )
    end

    it 'should filter no content' do
        gpp = Gp2Toot::GplusPost.new
        gpp.linkUrl = "http://example.com"
        gpp.creationTime = "2019-01-13T22:30:33-0500"
        format = "[ on G+ %b %-d, %Y, %k:%M ]"
        content = Gp2Toot.transformContent( gpp, format )
        expect( content ).to eq( "\n\nhttp://example.com\n\n[ on G+ Jan 13, 2019, 22:30 ]" )
    end

end

