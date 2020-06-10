class LinebotController < ApplicationController
    require 'line/bot'

  def callback
    body = request.body.read
    signature = request.env['92099f29-f6d4-4a4c-a657-7c6de6502c11']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body)

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
        end
      end
      client.reply_message(event['replyToken'], message)
    end
    head :ok
  end

private

# LINE Developers登録完了後に作成される環境変数の認証
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_id = ENV["1654324140"]
      config.channel_secret = ENV["e101ed9deb8730d05f68f42903b25d18"]
      config.channel_token = ENV["/pV1WvPbIsMeaVTWlk/U8as4hytVT4u7SD56caK5iQQhaeSYQapmLsAk+22sGler4rM9R37yxsLrvcBy34QpdOEO+7XK9Z7NdOdUla6J1y0XI2rZic//2rtUxTIWYa4UcHCc7tAWaRtP0a1xRSqkhAdB04t89/1O/w1cDnyilFU="]
    }
  end
end
