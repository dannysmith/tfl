require 'mechanize'
require 'money'

I18n.config.available_locales = :en

module TFL
  class Client
    attr_accessor :username, :password

    def initialize(args = {})
      self.username = args.fetch(:username)
      self.password = args.fetch(:password)
      raise "You must provide a username & password" unless self.username && self.password
    end

    def journeys(filter = {})
      @journeys ||= []
      if filter[:on]
        journeys_on_date(filter[:on].to_date)
      else
        @journeys
      end
    end

    def total(filter = {})
      js = journeys(on: filter[:on])
      js ? js.inject(0){ |sum, j| sum + j.fare } : Money.new(0, :gbp)
    end

    private

    def agent
      @agent ||= Mechanize.new
    end

    def login
      form = @page.forms.first
      form['UserName'] = username
      form['Password'] = password
      @page = form.submit
      card = @page.link_with(class: 'contactless-card')
      raise 'incorrect login or no contactless card' unless card
      @query = card.uri.query
    end

    def statement
      @page = agent.get("https://contactless.tfl.gov.uk/Statements/TravelStatement?#{@query}")
      if @page.uri.path == "/Login"
        login
        statement
      end
      @page
    end

    def select_period(period)
      form = statement.forms[2]
      form['SelectedStatementPeriod'] = [period]
      @page = form.submit
      if @page.uri.path == "/Login"
        login
        statement
        select_period(period)
      end
    end

    def dates
      journeys.collect{|j| j.date}.uniq
    end

    def cached_periods
      journeys.collect{|j| period_for_date(j.date)}.uniq
    end

    def period_for_date(date)
      "#{date.to_date.month}|#{date.to_date.year}"
    end

    def journeys_on_date(date)
      return journeys.select{|j| j.date == date.to_date} if cached_periods.include?(period_for_date(date))
      select_period(period_for_date(date))
      @page.search('.statements-list').each do |day_node|
        date = Date.parse(day_node.css('span[data-pageobject=statement-date]').text)
        day_node.search('.row').each do |journey_node|
          journey = Journey.new
          journey.date = date
          journey.from = journey_node.css('span[data-pageobject=journey-from]').text
          journey.to   = journey_node.css('span[data-pageobject=journey-to]').text
          journey.time = journey_node.css('span[data-pageobject=journey-time]').text
          journey.fare = journey_node.css('span[data-pageobject=journey-fare]').text
          journeys << journey
        end
      end
      return journeys.select{|j| j.date == date.to_date}
    end
  end
end
