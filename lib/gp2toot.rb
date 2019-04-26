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

    def initialize
      @baseUrl = 'https://masto.rootdc.xyz'
      @loggerOut = 'console'
      @directory = File.dirname( __FILE__ )
      @visibility = 'unlisted'
      @timeFormat = "[ originally posted on G+ on %b %-d, %Y, %k:%M ]"
      @limit = -1 #unlimited
      @throttle = 2
    end
  end

  class Gp2Toot
    
    def initialize( configuration )
      @configuration = configuration
      @varDir = @configuration.directory + '/../var/'

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
    
    def run( action )
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
          deletePosts
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

          params = { :visibility => @configuration.visibility }
          status = @mastodon.create_status( content + "\n" + appendText, params )
          sleep( @configuration.throttle )
          statusAry << status
          i = i + 1
          @logger.info( "posted status #{i} with id #{status.id}")
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

    def deletePosts
      Dir.glob( @varDir + '/posts-*' ) do |postIds|
        File.readlines( postIds).each do |id|
          @logger.debug( "deleting post #{id}")
          @mastodon.destroy_status( id )
          # we gotta do this otherwise we get throttled
          sleep( @configuration.throttle )
        end
      end
    end

  end

end
