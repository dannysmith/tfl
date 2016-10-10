require 'mechanize'
require 'money'

I18n.config.available_locales = :en

module TFL
  class Client
    attr_accessor :username, :password

    # Initialize a Client object with the user's TFL Credentials
    #
    # @return [TFL::Client] a client object to the TFL Contactless website.
    def initialize(args = {})
      @cards = []
      @journeys = []
      self.username = args.fetch(:username)
      self.password = args.fetch(:password)
      raise "You must provide a username & password." unless self.username && self.password
    end

    # @method journeys
    # @param [Hash] opts additional request options (e.g. date: Date.today, card: cards.first)
    # @return [Journeys] all journeys for the given options
    # with no options it will return all cached journeys.
    def journeys(opts = {})
      if opts.any?
        request_journeys(opts)
      else
        @journeys
      end
    end

    # @method total
    # @return Money total value of all journeys
    def total(opts = {})
      js = journeys(opts)
      js ? js.inject(0){ |sum, j| sum + j.fare } : Money.new(0, :gbp)
    end

    # @method cards
    # @return [Card] all cards for this user
    def cards(opts = {})
      @page = request('https://contactless.tfl.gov.uk/MyCards')
      cards = @page.search('#contactless-card-list a[data-pageobject=mycards-card-cardlink]')
      cards.each do |c|
        card = TFL::Card.new
        card.id            = c.attributes['href'].value.to_s[/\/Card\/View\?pi=(.*)/,1]
        card.network       = c.css('h3.current-nickname span.sr-only').text.to_s[/(MasterCard|Visa)/]

        card.last_4_digits = if c.css('span[data-pageobject="view-card-last4digits"]').empty? then
          c.css('span.view-card-nickname').text.to_s[/\d{4}/]
        else
          c.css('span[data-pageobject="view-card-last4digits"]').text
        end

        card.expiry        = c.css('span[data-pageobject=view-card-cardexpiry]').text.to_s.strip
        @cards << card unless @cards.find{|c| c.id == card.id}
      end
      @cards
    end

    private

    def agent
      @agent ||= Mechanize.new
    end

    def cache_key(card_id, date)
      "#{card_id}-#{date_period(Utils.date_normalizer(date))}"
    end

    def cached_periods
      @journeys.collect{|j| cache_key(j.card_id, j.date) }.uniq
    end

    def date_period(date)
      date = Utils.date_normalizer(date)
      "#{date.month}|#{date.year}"
    end

    def date_period_cached?(opts)
      card_id = opts[:card] ? opts[:card].id : @current_card_id
      cached_periods.include?(cache_key(card_id, opts[:date]))
    end

    def request(url)
      @page = agent.get(url)
      if @page.uri.path == "/Login"
        login_handler
        request(url)
      end
      @page
    end

    def login_handler
      form = @page.forms.first
      form['UserName'] = username
      form['Password'] = password
      @page = form.submit
      raise 'The username or password provided is incorrect.' if @page.uri.path == '/Login'
      raise 'No contactless card on this TFL account.' unless @page.link_with(class: 'contactless-card')
    end

    def statement
      request('https://contactless.tfl.gov.uk/Statements/ShowStatement')
    end

    def select_options(opts)
      period = date_period(opts[:date])
      form = statement.forms[3]
      form['PaymentCardId'] = [opts[:card].id] if opts[:card]
      form['SelectedStatementType'] = ['Payments'] # ['Journeys']
      form['SelectedStatementPeriod'] = [period]
      @page = form.submit
      if @page.uri.path == "/Login"
        login_handler
        select_options(opts)
      end
      @current_card_id = @page.search('#CurrentCard').first.attributes['data-card-id'].value
      @page
    end

    def request_journeys(opts)
      return filtered_journeys(opts) if date_period_cached?(opts)

      select_options(opts)

      @page.search('.statements-list').each do |day_node|
        day_node_date = Date.parse(day_node.css('span[data-pageobject=statement-date]').text)
        day_node.search('.row').each do |journey_node|
          journey = Journey.new
          journey.card_id = @current_card_id
          journey.date    = day_node_date
          journey.from    = journey_node.css('span[data-pageobject=journey-from]').text
          journey.to      = journey_node.css('span[data-pageobject=journey-to]').text
          journey.time    = journey_node.css('span[data-pageobject=journey-time]').text
          journey.fare    = journey_node.css('span[data-pageobject=journey-fare]').text
          @journeys << journey
        end
      end
      return filtered_journeys(opts)
    end

    def filtered_journeys(opts)
      date = Utils.date_normalizer(opts[:date])
      journeys = @journeys
      journeys = journeys.select{ |j| j.date == date } if opts[:date]
      journeys = journeys.select{ |j| compare_card_ids(j.card_id, opts[:card].id) } if opts[:card]
      journeys
    end

    def compare_card_ids(id1, id2)
      id1[0..-8] == id2[0..-8]
    end
  end
end
