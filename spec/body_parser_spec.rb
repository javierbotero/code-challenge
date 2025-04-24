# string_frozen_literal: true
require 'rspec'
require 'json'
require 'webmock/rspec'
require 'byebug'

require_relative '../files/body_parser'

RSpec.describe BodyParser do
  let(:url) { "https://raw.githubusercontent.com/serpapi/code-challenge/master/files/van-gogh-paintings.html" }
  let(:html_fixture) { File.read('files/van-gogh-paintings.html') }
  let(:parse) { BodyParser.new(url) }
  let(:json_response) { JSON.parse(parse.images) }
  let(:expected_json) { JSON.parse(File.read('files/expected-array.json')) }

  before do
    stub_request(:get, url)
      .to_return(status: 200, body: html_fixture, headers: { 'Content-Type' => 'text/html' })

    parse.call
  end

  describe '#call' do
    it 'brings expected array' do
      expect(json_response['artworks']).to be_a(Array)
    end

    it 'test agains expected json' do
      expect(json_response['artworks'].map{ |obj| obj['extensions'] })
        .to eq(expected_json['artworks'].map{ |obj| obj['extensions'] })
      expect(json_response['artworks'].map{ |obj| obj['name'] })
        .to eq(expected_json['artworks'].map{ |obj| obj['name'] })
      expect(json_response['artworks'].map{ |obj| obj['link'] })
        .to eq(expected_json['artworks'].map{ |obj| obj['link'] })
    end
  end

  describe 'with other example 1' do
    let(:html_fixture) { File.read('files/botero-paintings.html') }

    it 'brings expected array' do
      expect(json_response['artworks']).to be_a(Array)
    end

    it 'expect proper fields' do
      painting = json_response['artworks'].first

      expect(painting['extensions'].all?{ |ext| ext.match(/\d{4}/) }).to be_truthy
      expect(painting['name']).to be_a(String)
      expect(painting['link']).to be_a(String)
    end
  end
end
