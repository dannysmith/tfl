module TFL
  class Journey
    attr_accessor :from, :to, :time, :fare, :date

    def fare=(string)
      @fare = Money.new(string.gsub('£', '').to_f * 100, :gbp)
    end
  end
end
