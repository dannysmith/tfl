require 'spec_helper'

describe TFL::Utils do
  describe '.date_normalizer' do
    it 'normalizes nil to todays date' do
      expect(TFL::Utils.date_normalizer).to eq(Date.today)
    end

    it 'normalizes a String to date' do
      expect(TFL::Utils.date_normalizer('2014-01-01')).to eq(Date.parse('2014-01-01'))
    end

    it 'normalizes a DateTime to date' do
      expect(TFL::Utils.date_normalizer(DateTime.now)).to eq(DateTime.now.to_date)
    end

    it 'normalizes a Time to date' do
      expect(TFL::Utils.date_normalizer(Time.now)).to eq(Time.now.to_date)
    end
  end
end
