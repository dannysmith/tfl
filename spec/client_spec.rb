require 'spec_helper'
require "net/https"


describe TFL::Client do
  describe '.initialize' do
    it 'should raise an error if no username' do
      expect { TFL::Client.new }.to raise_error(KeyError)
    end

    it 'should raise an error if no password' do
      expect { TFL::Client.new(username: 'random@example.com') }.to raise_error(KeyError)
    end

    it 'should not raise an error if both username & password' do
      expect { TFL::Client.new(username: 'random@example.com', password: 'arandompassword') }.not_to raise_error
    end
  end

  describe '#cards' do
    before(:each) do
      @tfl = TFL::Client.new(username: 'random@example.com', password: 'arandompassword')
      my_cards = File.read('./spec/fixtures/my_cards.html')
      FakeWeb.allow_net_connect = false
      FakeWeb.register_uri(:get, 'https://contactless.tfl.gov.uk/MyCards', body: my_cards, content_type: 'text/html')
    end

    it 'should parse the correct last 4 digits' do
      expect(@tfl.cards.first.last_4_digits).to eq('1234')
      expect(@tfl.cards.last.last_4_digits).to eq('5678')
    end

    it 'should parse the correct card network' do
      expect(@tfl.cards.first.network).to eq('MasterCard')
      expect(@tfl.cards.last.network).to eq('Visa')
    end

    it 'should parse the correct expiry' do
      expect(@tfl.cards.first.expiry).to eq('01/2020')
      expect(@tfl.cards.last.expiry).to eq('12/2025')
    end

    it 'should parse the correct card id' do
      expect(@tfl.cards.first.id).to eq('1wRXbW9Y4gzNpG8MhTorM2wRY1jg')
      expect(@tfl.cards.last.id).to eq('J16kuCuoJhMzHf8Bc0udT7iWJ0BU')
    end
  end

  describe '#journeys' do
    before(:each) do
      @tfl = TFL::Client.new(username: 'random@example.com', password: 'arandompassword')
      @date = Date.parse('2016-06-06')
      @card_id = '1wRXbW9Y4gzNpG8MhTorM2wRY1jg'

      statement = File.read('./spec/fixtures/show_statement.html')
      FakeWeb.allow_net_connect = false
      FakeWeb.register_uri(:get, 'https://contactless.tfl.gov.uk/Statements/ShowStatement', body: statement, content_type: 'text/html')
      FakeWeb.register_uri(:post, 'https://contactless.tfl.gov.uk/Statements/Refresh', status: ['302', 'Found'], location: 'https://contactless.tfl.gov.uk/Statements/ShowStatement')
    end

    it 'should have the correctly selected card id' do
      journeys = @tfl.journeys(date: @date)
      expect(journeys.first.card_id).to eq(@card_id)
    end

    it 'should parse the correct amount of journeys for the date' do
      journeys = @tfl.journeys(date: @date)
      expect(journeys.count).to eq(3)
    end

    it 'should parse the correct date for a journey' do
      journeys = @tfl.journeys(date: @date)
      expect(journeys.first.date).to eq @date
    end

    it 'should parse the correct from element' do
      journeys = @tfl.journeys(date: @date)
      expect(journeys[0].from).to eq 'East Putney'
      expect(journeys[1].from).to eq 'Moorgate'
      expect(journeys[2].from).to eq 'Bond Street'
    end

    it 'should parse the correct to element' do
      journeys = @tfl.journeys(date: @date)
      expect(journeys[0].to).to eq 'Old Street'
      expect(journeys[1].to).to eq 'Goodge Street'
      expect(journeys[2].to).to eq 'East Putney'
    end

    it 'should parse the correct time element' do
      journeys = @tfl.journeys(date: @date)
      expect(journeys[0].time).to eq '09:21 - 10:09'
      expect(journeys[1].time).to eq '14:10 - 14:33'
      expect(journeys[2].time).to eq '15:46 - 16:18'
    end

    it 'should parse the correct fare element' do
      journeys = @tfl.journeys(date: @date)
      expect(journeys[0].fare).to eq Money.new(290, :gbp)
      expect(journeys[1].fare).to eq Money.new(240, :gbp)
      expect(journeys[2].fare).to eq Money.new(120, :gbp)
    end
  end

  describe '#total' do
    before(:each) do
      @tfl = TFL::Client.new(username: 'random@example.com', password: 'arandompassword')
      @date = Date.parse('2016-06-05')
      statement = File.read('./spec/fixtures/show_statement.html')
      FakeWeb.allow_net_connect = false
      FakeWeb.register_uri(:get, 'https://contactless.tfl.gov.uk/Statements/ShowStatement', body: statement, content_type: 'text/html')
      FakeWeb.register_uri(:post, 'https://contactless.tfl.gov.uk/Statements/Refresh', status: ['302', 'Found'], location: 'https://contactless.tfl.gov.uk/Statements/ShowStatement')
    end

    it 'should calculate the correct daily total' do
      expect(@tfl.total(date: @date)).to eq Money.new(400, :gbp)
    end
  end
end
