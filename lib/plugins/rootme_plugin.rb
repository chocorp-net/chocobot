# frozen_string_literal: true

require_relative '../query_forge'

# Pulls RootMe scores for my friend
# TODO: make friend list a parameter
class Plugin
  def stop; end

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
      response = QueryForge.get_as_json("#{url}/#{v}",
                                        cookie: "api_key=#{@rootme_apikey}")
      # response can be an array lmao
      response = response[0] if response.is_a? Array
      return nil if response.nil? || response.key?(:error)

      scores[k] ||= response['validations']
    end
    scores
  end

  def pull_chall_info(chall_id)
    url = "#{@rootme_url}/challenges/#{chall_id}"
    QueryForge.get_as_json(url, cookie: "api_key=#{@rootme_apikey}")
  end

  def build_solved_chall_msg(player, chall)
    cdata = pull_chall_info(chall[:id_challenge])
    str = "🚩 `[#{cdata['rubrique']}]` #{player} just flagged "
    str += "**#{cdata['titre']}**"
    str += " (#{cdata['score']} points)" if cdata['score'] != '0'
    "#{str} !"
  end

  def compare_scores
    scores = pull_scores
    # If for some reason couldn't pull scores already,
    # just update them
    if @scores == nil
      @scores = scores
      return
    end
    buffer = []  # One entry per chall achieved

    @scores.each do |player, _|
      (scores[player] - @scores[player]).each do |chall|
        buffer.append build_solved_chall_msg(player, chall)
      end
    end
    @scores = scores
    bot.info(buffer.join('\n')) if buffer.length.positive?
  end
end
