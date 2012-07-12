# -*- coding: utf-8 -*-

###############################################################################
#     Copyright © 2012 Hector Sanjuan                                         #
#                                                                             #
#     This file is part of Magic8Ball.                                        #
#                                                                             #
#     Magic8Ball is free software: you can redistribute it and/or modify      #
#     it under the terms of the GNU General Public License as published by    #
#     the Free Software Foundation, either version 3 of the License, or       #
#     (at your option) any later version.                                     #
#                                                                             #
#     Magic8Ball is distributed in the hope that it will be useful,           #
#     but WITHOUT ANY WARRANTY; without even the implied warranty of          #
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           #
#     GNU General Public License for more details.                            #
#                                                                             #
#     You should have received a copy of the GNU General Public License       #
#     along with Magic8Ball.  If not, see <http://www.gnu.org/licenses/>.     #
#                                                                             #
###############################################################################

$: << File.dirname(__FILE__) # Ruby 1.9 includes

require 'rubygems'
require 'twitter_oauth'
require 'Magic8Ball'

# This class implements a Twitter bot for Magic8Ball
# Bot is able to authenticate in Twitter and answer mentions automaticly
class Magic8BallBot

    # Instantiate a new bot
    # @param [Integer] refresh_interval interval in seconds to check for new mentions
    # @param [Hash] auth credentials for oAuth: :consumer_key, :consumer_secret, :token and :secret
    def initialize(refresh_interval = 30, auth = {})
        @refresh_interval = refresh_interval
        @client = TwitterOAuth::Client.new(
                                  :consumer_key => auth[:consumer_key],
                                  :consumer_secret => auth[:consumer_secret],
                                  :token => auth[:access_token],
                                  :secret => auth[:access_secret]
                                           )
        @ball = Magic8Ball.new
    end

    # Run the twitter bot
    # @param [Hash] opts options. Currently :run_as_daemon
    def run(opts = {})
        if !@client.authorized?
            $stderr.puts "Seems authorization did not work. Aborting run"
            return
        end

        # Let's become a daemon!
        if opts[:run_as_daemon]
            puts "Going background..."
            daemonize()
        end

        # Extract the last mention of the timeline
        # and set last to its ID so we start answering from that one.
        last_mention = @client.mentions({:count => 1})
        if last_mention.size > 0
            last = last_mention[0]['id'].to_i
        else
            last = 0
        end

        # Program loop
        while true do
            begin
                # Fetch last 20 mentions from the last one answered
                mentions = @client.mentions({:since_id => last})

                mentions.each do | mention |
                    next if !mention['id'] #in case of error, we skip

                    mention_id = mention['id'].to_i
                    username = mention['user']['screen_name']
                    if mention_id > last then last = mention_id end
                    message = "@#{username}: #{@ball.ask()}"
                    @client.update(message,
                                   { :in_reply_to_status_id => mention_id})
                end

                sleep @refresh_interval
            rescue
                #... avoid any crash
            end
        end
    end

    # Get this bot authorized. Will ask user interactively for oauth code.
    # @param [String] consumer_key the Twitter application consumer key
    # @param [String] consumer_secret the Twitter application consumer secret
    def self.authorize(consumer_key, consumer_secret)
        client = TwitterOAuth::Client.new(
                                          :consumer_key => consumer_key,
                                          :consumer_secret => consumer_secret
                                          )
        request_token = client.request_token()
        puts "Please visit: #{request_token.authorize_url}"
        print "Write here the oAuth code: "
        oauth = gets.chomp!
        access_token = client.authorize(request_token.token,
                                        request_token.secret,
                                        :oauth_verifier => oauth)
        if client.authorized?
            puts "Access token: #{access_token.token}"
            puts "Access secret: #{access_token.secret}"
        else
            puts "Error authorizing!"
        end
    end

    private

    # Daemonizes this process
    def daemonize
        if RUBY_VERSION < "1.9"
            exit if fork
            Process.setsid
            exit if fork
            Dir.chdir "/"
            STDIN.reopen "/dev/null"
            STDOUT.reopen "/dev/null", "a"
            STDERR.reopen "/dev/null", "a"
        else
            Process.daemon
        end
    end
end
