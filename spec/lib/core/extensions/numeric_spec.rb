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
end
