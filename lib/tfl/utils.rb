module TFL
  module Utils
    extend self

    # @method date_normalizer
    # @param date_attribute, can be a String e.g. ('2014-01-01'), Date e.g. (Date.today), DateTime e.g. (DateTime.now), Time e.g. (Time.now)
    # @return normalized Date object
    def date_normalizer(date_attribute = nil)
      case date_attribute.class.name
      when 'String'
        Date.parse(date_attribute)
      when 'Date'
        date_attribute
      when 'DateTime'
        date_attribute.to_date
      when 'Time'
        date_attribute.to_date
      else
        Date.today
      end
    end
  end
end
