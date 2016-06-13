module TFL
  class Card
    attr_accessor :id, :last_4_digits, :expiry, :network, :journeys

    def to_s
      "#<TFL::Card id='#{id}''>"
    end
  end
end
