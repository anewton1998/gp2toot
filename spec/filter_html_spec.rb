# Copyright (C) 2019 Andrew Newton

require 'spec_helper'
require_relative '../lib/gp2toot'

describe 'filter html' do

    it 'should filter simple content' do
        frag = 'foo bar'
        text = Gp2Toot.filterHTML( frag )
        expect( text ).to eq( frag )
    end

    it 'should filter paragraphs' do
        frag = 'foo <p>bar</p>'
        text = Gp2Toot.filterHTML( frag )
        expect( text ).to eq( "foo bar" )
    end

    it 'should filter break' do
        frag = 'foo <br>bar'
        text = Gp2Toot.filterHTML( frag )
        expect( text ).to eq( "foo \nbar" )
    end

    it 'should filter link' do
        frag = 'foo <a href="baz">bar</a>'
        text = Gp2Toot.filterHTML( frag )
        expect( text ).to eq( 'foo bar (baz)' )
    end

end

