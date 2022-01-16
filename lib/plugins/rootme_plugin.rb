# frozen_string_literal: true

require_relative '../query_forge'

# Pulls RootMe scores for my friend
# TODO: make friend list a parameter
class Plugin
  private

  def initialize(scheduler, bot)
    @rootme_url = ENV['ROOTME_URL']
    @rootme_apikey = ENV['ROOTME_APIKEY']
    @scores = pull_scores

    scheduler.every '1h' do
      compare_scores
    end
  end

  def pull_scores
    url = "#{@rootme_url}/auteurs"
    scores = { 'mulog' => 62_550, 'beubz' => 469_552, 'Mcdostone' => 120_259 }
    scores.each do |k, v|
      response = QueryForge.get_as_json("#{url}/#{v}", cookie: "api_key=#{@rootme_apikey}")
      return nil if response.nil? || response.has_key?(:error)

      scores[k] = response['validations']
    end
    scores
  end

  def compare_scores
    scores = pull_scores
    buffer = []  # One entry per chall achieved

    @scores.each do |player, _|
      (scores[player] - @scores[player]).each do |chall|
        cdata = pull_chall_info(chall[:id_challenge])
        str = "🚩 `[#{cdata[:rubrique]}]` #{player} just flagged "
        if cdata[:score] != '0'
          str += "**#{cdata[:titre]}** (#{cdata[:score]} points)"
        end
        buffer.append("#{str} !")
      end
    end
    @scores = scores
    if buffer.length.positive?
      bot.info buffer.join '\n'
    end
  end
end
