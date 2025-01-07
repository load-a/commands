RSpec.describe Numeric do
  describe '#not_positive?' do
    it 'returns true if self is less than 0' do
      expect(-10.not_positive?).to be(true)
    end
  end

  describe '#not_negative?' do
    it 'returns true if self is greater than 0' do
      expect(256.not_negative?).to be(true)
    end
  end

  describe '#not_zero?' do
    it 'returns true if self is not zero' do
      expect(0.5.not_zero?).to be(true)
    end
  end

  describe '#divisible_by?' do
    it 'returns true if self is evenly divisible by the given divisor' do
      expect(25.divisible_by?(5)).to be(true)
    end

    it 'also works with floating point numbers' do
      expect(2.5.divisible_by?(0.5)).to be(true)
      expect(3.3.divisible_by?(0.5)).to be(false)
    end

    it 'raises a ZeroDivisionError if divisor is zero' do
      expect { 25.divisible_by?(0) }.to raise_error(ZeroDivisionError)
    end
  end

  describe '#round_up' do
    it 'rounds self up to the nearest increment' do
      expect(103.round_up(5)).to eq(105)
    end
  end

  describe '#round_down' do
    it 'rounds self down to the nearest increment' do
      expect(103.round_down(5)).to eq(100)
    end
  end

  describe '#natural_number?' do
    it 'rejects zero by default' do 
      expect(0.natural_number?).to eq(false)
    end

    it 'can include zero if specified' do
      expect(0.natural_number?(include_zero: true)).to eq(true)
    end

    it 'rejects floating point numbers by default' do
      expect(1.0.natural_number?).to eq(false)
    end

    it 'can include zero if specified' do
      expect(1.0.natural_number?(integer_value: true)).to eq(true)
    end 

    it 'determines whether a number fits into the Natural Numbers category' do
      expect(0.natural_number?).to eq(false)
      expect(40.natural_number?).to eq(true)
      expect(0b10011.natural_number?).to eq(true)
      expect(0xffea.natural_number?).to eq(true)
      expect(-37.natural_number?).to eq(false)
      expect(19.natural_number?).to eq(true)
    end

    it 'can apply decimal precision to a defined tolerance (1e-10 by default)' do
      expect(1.000001.natural_number?(integer_value: true, tolerance: 1e-5)).to eq(true)
      expect(1.00001.natural_number?(integer_value: true, tolerance: 1e-5)).to eq(false)

      expect(1.00000000001.natural_number?(integer_value: true, tolerance: 1e-10)).to eq(true)
      expect(1.0000000001.natural_number?(integer_value: true, tolerance: 1e-10)).to eq(false)

      expect(1.0000000000000001.natural_number?(integer_value: true, tolerance: 1e-15)).to eq(true)
      expect(1.000000000000001.natural_number?(integer_value: true, tolerance: 1e-15)).to eq(false)
    end
  end
end
