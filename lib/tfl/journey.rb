module TFL
  class Journey
    attr_accessor :from, :to, :time, :fare, :date, :card_id

    def fare=(string)
      @fare = Money.new(string.gsub('£', '').to_f * 100, :gbp)
    end

    def tapped_in_at
      self.time[/^(\d\d:\d\d)( - (\d\d:\d\d|--:--))?$/, 1]
    end

    def tapped_out_at
      self.time[/^(\d\d:\d\d|--:--)( - (\d\d:\d\d))?$/, 3]
    end
  end
end
