RSpec.describe String do
  describe '#numeric?' do
    context 'when the entire string is a decimal, binary, octal or hexadecimal value' do
      it 'can interpret decimal integers' do
        expect("123".numeric?).to eq(true)
      end

      it 'can interpret negative numbers' do
        expect("-123".numeric?).to eq(true)
        expect("-0b1001".numeric?).to eq(true)
        expect("-0xace1".numeric?).to eq(true)
      end

      it 'can interpret floating point decimal numbers' do
        expect("0.123".numeric?).to be(true)
      end

      it 'can interpret binary (0b) integers' do
        expect("0b011010".numeric?).to be(true)
      end

      it 'can interpret octal integers' do
        expect("0176".numeric?).to be(true)
      end

      it 'can interpret hexadecimal integers' do
        expect("0xffa3".numeric?).to be(true)
      end
    end

    context 'when the string is not completely numeric' do
      it 'will return false if a number is formatted incorrectly' do
        expect('0xa 445'.numeric?).to be(false)
        expect('0b12345'.numeric?).to be(false)
        expect('09'.numeric?).to be(true)
      end

      it 'will return false if the whole string is not a number' do
        expect('Hello 1234'.numeric?).to be(false)
        expect('500km'.numeric?).to be(false)
      end

      it 'will return false if the string contains a symbol' do
        expect('$12.50'.numeric?).to be(false)
      end

      it 'does not ignore leading/trailing whitespace' do
        expect(' 134 '.numeric?).to be(false)
      end

      it 'can interpret scientific notation' do
        expect('1.091e4'.numeric?).to be(true)
      end
    end
  end

  describe '#to_numeric' do
    it 'converts integers to Integers' do
      expect('123'.to_numeric).to eq(123)
    end

    it 'converts decimals to Floats' do
      expect('0.123'.to_numeric).to eq(0.123)
    end

    it 'converts scientific notations to Floats' do
      expect('1.091e4'.to_numeric).to eq(1.091e4)
      expect('1.091e4'.to_numeric).to be_a(Float)
    end

    it 'converts negative numbers correctly' do
      expect('-8'.to_numeric).to eq(-8)
    end

    it 'converts large and small numbers, and scientific notation correctly' do
      expect('1e100'.to_numeric).to eq(1e100)
      expect('1e-100'.to_numeric).to eq(1e-100)
      expect('9999999999999999999999'.to_numeric).to eq(9999999999999999999999)
    end

    it 'handles case insensitivity' do
      expect('0XAF05'.to_numeric).to eq(0xaf05)
    end

    context 'numbers with leading zeros' do
      it 'converts binary into Binary Integers' do
        expect('0b1001'.to_numeric).to eq(0b1001)
      end

      it 'converts octal into Octal Integers' do
        expect('0o176'.to_numeric).to eq(0176)
      end

      it 'recognizes a difference between octal numbers and decimal integers with leading zeros' do
        expect('0176'.to_numeric).to eq(0176)
        expect('0189'.to_numeric).to eq(189)
      end

      it 'converts hexadecimal into Hexadecimal Integers' do
        expect('0xffa3a'.to_numeric).to eq(0xffa3a)
      end
    end

    context 'string is not numeric' do
      it 'returns the default value for invalid inputs' do
        expect('abc'.to_numeric).to eq(0)
        expect('def'.to_numeric('NaN')).to match('NaN')
        expect('ghi'.to_numeric(-1)).to eq(-1)
        expect('jkl'.to_numeric(nil)).to be(nil)
      end

      it 'returns the default value for mixed inputs' do
        expect('$256'.to_numeric).to eq(0)
      end

      it 'returns the default for ambiguous inputs' do
        expect('0.1.2'.to_numeric).to eq(0)
        expect('5/12'.to_numeric).to eq(0)
        expect('0b20'.to_numeric).to eq(0)
      end
    end
  end
end
