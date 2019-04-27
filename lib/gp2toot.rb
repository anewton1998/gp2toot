# Copyright (C) 2019 Andrew Newton
require 'logger'
require 'pp'
require 'json'
require 'date'
require 'mastodon'


module Gp2Toot

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield( configuration )
  end


  class Configuration
    attr_accessor :baseUrl
    attr_accessor :bearerToken
    attr_accessor :loggerOut
    attr_accessor :loggerLevel
    attr_accessor :directory
    attr_accessor :acct
    attr_accessor :takeoutDir
    attr_accessor :visibility
    attr_accessor :timeFormat
    attr_accessor :limit
    attr_accessor :throttle
    attr_accessor :maxLength

    def initialize
      @baseUrl = 'https://masto.rootdc.xyz'
      @loggerOut = 'console'
      @directory = File.dirname( __FILE__ )
      @visibility = 'unlisted'
      @timeFormat = "[ originally posted on G+ on %b %-d, %Y, %k:%M ]"
      @limit = -1 #unlimited
      @throttle = 2
      @maxLength = 500
    end
  end

  class Gp2Toot
    
    def initialize( configuration )
      @configuration = configuration
      @varDir = @configuration.directory + '/../var/'
      @current_throttle = @configuration.throttle

      if @configuration.loggerOut == 'console'
        @logger = Logger.new( STDOUT ) if @configuration.loggerOut == 'console'
      else
        Dir.mkdir( @varDir ) unless File.exists?( @varDir )
        @logger = Logger.new( @varDir + @configuration.loggerOut )
      end
      
      case @configuration.loggerLevel
      when 'warn'
        @logger.level=Logger::WARN
      when 'debug'
        @logger.level=Logger::DEBUG
      when 'info'
        @logger.level=Logger::INFO
      else
        @logger.level=Logger::INFO
      end
      
      @logger.debug( "Configuration looks good." )

    end
    
    def run( action, params )
      raise ArgumentError unless action

      @mastodon = Mastodon::REST::Client.new( base_url: @configuration.baseUrl, bearer_token: @configuration.bearerToken );

      begin

        @logger.info( "Crawling #{@configuration.takeoutDir}" )
        stream = @configuration.takeoutDir + '/Google+ Stream'

        case action
        when :post
          @logger.info( "posting statuses" )
          postStatuses( stream )
        when :deletePosts
          @logger.info( "deleting past statuses" )
          deletePosts( params )
        when :analyze
          @logger.info( "doing analysis" )
          analyze( stream )
        else
          raise ArgumentError( "unknown action" )
        end

      rescue Interrupt => e
        @logger.info("interrupt received")
      end

    end

    def postStatuses( stream )
      posts = stream + '/Posts'
      statusAry = []
      i = 1
      Dir.glob( posts + '/*.json' ) do |rb_file|
        @logger.debug( "found #{rb_file}" )
        content,photo,creationTime = postData( rb_file )
        @logger.debug( "content #{content}")
        @logger.debug( "photo #{photo}")
        @logger.debug( "creation time #{creationTime}")
        date = DateTime.parse( creationTime )
        appendText = date.strftime(@configuration.timeFormat)
        @logger.debug( "append text is #{appendText}")

        params = { :visibility => @configuration.visibility, :created_at => date }
        status = throttle{ @mastodon.create_status( content + "\n" + appendText, params ) }
        statusAry << status
        @logger.info( "posted status #{i} with id #{status.id}")
        i = i + 1
        break if @configuration.limit > 0 && i > @configuration.limit
      end
      writeStatusIds( statusAry )
    end

    def postData( post )
      f = File.open( post, 'r') 
      t = f.read
      f.close
      j = JSON.parse( t )
      content = j[ "content" ]
      photo = nil
      photo = j[ "link" ][ "imageUrl" ] if j[ "link" ] and j[ "link" ][ "imageUrl" ]
      creationTime = j[ "creationTime" ]
      return content, photo, creationTime
    end

    def writeStatusIds( statusAry )
      now = DateTime.now()
      f = File.open( @varDir + '/posts-' + now.iso8601(), 'w' )
      statusAry.each do |status|
        f.write( status.id )
        f.write( "\n" )
      end
      f.close
    end

    def deletePosts( params )
      case params[ :deletePosts ]
      when :all
        Dir.glob( @varDir + '/posts-*' ) do |postIds|
          deletePostIds( postIds )
        end
      when :last
        postIds = Dir.glob( @varDir + '/posts-*' ).max_by {|f| File.mtime(f) }
        deletePostIds( postIds )
      end
    end

    def deletePostIds( postIds )
      @logger.debug( "reading postIds from #{postIds}" )
      File.readlines( postIds ).each do |id|
        @logger.info( "deleting post #{id}")
        throttle{ @mastodon.destroy_status( id ) }
      end
    end

    def throttle( &block )
      begin
        retval = yield
        sleep( @current_throttle )
        retval
      rescue Mastodon::Error::TooManyRequests => e
        @logger.warn( "throttled... backing off: #{e}" )
        @current_throttle = @current_throttle + 1
        throttle( &block )
      end
    end

    def analyze( stream )
      posts = stream + '/Posts'
      numPosts = 0
      numExeedingLength = 0
      numWithPhoto = 0
      Dir.glob( posts + '/*.json' ) do |rb_file|
        @logger.debug( "found #{rb_file}" )
        content,photo,creationTime = postData( rb_file )
        numPosts += 1
        numExeedingLength += 1 if content && content.length > @configuration.maxLength
        numWithPhoto += 1 if photo
      end
      @logger.info( "Number of posts: #{numPosts}" )
      @logger.info( "Number of posts exceeding #{@configuration.maxLength} character limit: #{numExeedingLength}" )
      @logger.info( "Number of posts with photo links: #{numWithPhoto}" )      
    end 

  end #end class gp2toot

end #end module
