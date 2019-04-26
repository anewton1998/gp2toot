require 'logger'
require 'pp'
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

    def initialize
      @baseUrl = 'https://masto.rootdc.xyz'
      @loggerOut = 'console'
      @directory = File.dirname( __FILE__ )
    end
  end

  class Gp2Toot
    
    def initialize( configuration )
      @configuration = configuration
      @varDir = @configuration.directory + '/../var/'

      if @configuration.loggerOut == 'console'
        @logger = Logger.new( STDOUT ) if @configuration.loggerOut == 'console'
      else
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
      
      @logger.info( "Looking through Takeout" )

    end
    
    def run
      mastodon = Mastodon::REST::Client.new( base_url: @configuration.baseUrl, bearer_token: @configuration.bearerToken );

      begin

        loop do

          if @configuration.chatEnabled
            @chatIntervalCount = @chatIntervalCount + 1
            if @chatIntervalCount == @configuration.chatInterval
              chat( mastodon )
              @chatIntervalCount = 0
            end
          end

          if @configuration.followEnabled
            @followIntervalCount = @followIntervalCount + 1
            if @followIntervalCount == @configuration.followInterval
              follow( mastodon )
              @followIntervalCount = 0
            end
          end

          if @configuration.tagChatEnabled
            @tagChatIntervalCount = @tagChatIntervalCount + 1
            if @tagChatIntervalCount == @configuration.tagChatInterval
              tagChat( mastodon )
              @tagChatIntervalCount = 0
            end
          end

          sleep 1

        end

      rescue Interrupt => e
        @logger.info("interrupt received")
      end

    end

    def chat( mastodon )

      if @sinceId
        @logger.info "fetching statuses since #{@sinceId}"
        toots = mastodon.home_timeline(since_id: @sinceId)
      else
        @logger.info "fetching last 25 statuses"
        toots = mastodon.home_timeline(limit: 25)
      end

      toots.each do |toot|
        @logger.debug("examining status #{toot.id}")
        if @sinceId == nil
          @sinceId = toot.id.to_i
        elsif @sinceId < toot.id.to_i
          @sinceId = toot.id.to_i
        end
        toot.mentions.each do |mention|
          if mention.acct == @configuration.acct
            @logger.debug("mentioned in status #{toot.id}")
            content = toot.content.gsub( %r{</?[^>]+?>} , '')
            content.gsub!( %r{@\w+}, '' )
            @logger.info( "#{toot.account.acct} :: #{content}" )
            reply = @eliza.processInput( content )
            @logger.info( "#{@configuration.acct} :: #{reply}" )
            mastodon.create_status( reply, toot.id )
          end
        end
      end

    end

  end

end
