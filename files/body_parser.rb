require 'httparty'
require 'nokogiri'
require 'json'

class BodyParser
  attr_reader :query, :url, :document, :images

  def initialize(url)
    @url = url
  end

  def call
    begin
      response = HTTParty.get(url)
      if response.success?
        @document = Nokogiri::HTML(response.body)
        @images = { artworks: get_images }.to_json
      else
        warn "HTTP Error fetching #{url}: #{response.code}"
      end
    rescue StandardError => e
      warn "Error fetching or parsing: #{e.message}"
      self.document = nil
      self.images = nil
    end
  end

  private

  def get_images
    candidate_images = document.css('a > img')
    extract_data(candidate_images)
  end

  def extract_data(candidate_images)
    candidate_images.map do |image|
      anchor = image.parent
      next unless anchor && anchor.name == 'a' && anchor['href'].match(/\/search\?/)

      div = anchor.css('div').first
      next unless div && div.name == 'div'

      extensions = div.children
                      .map(&:text)
                      .select{ |ext| ext.match(/\d{4}/) }

      {
        name: image['alt'],
        extensions: extensions.any? ? extensions : nil,
        link: "https://www.google.com#{anchor['href']}",
        image: image['src']
      }
    end.compact
  end
end
