RSpec.describe Normalize do
  describe 'to_array' do
    it 'returns the object as an array' do
      expect(Normalize.to_array('abc')).to match_array(['abc'])
      expect(Normalize.to_array([1, 2, 3])).to match_array([1, 2, 3])
    end

    context 'when "flatten:" is used' do
      before do
        @nested_array = ['abc', [1, 2, 3], ['456', ['789']]]
      end

      it 'does not flatten the array if "flatten:" is false (default)' do
        expect(Normalize.to_array(@nested_array, flatten: false)).to match_array(@nested_array)
      end

      it 'completely flattens the array if "flatten:" is true' do
        expect(Normalize.to_array(@nested_array, flatten: true)).to match_array(@nested_array.flatten)
      end

      it 'flattens the array to the desired depth if "flatten:" is an integer' do
        expect(Normalize.to_array(@nested_array, flatten: 3)).to match_array(@nested_array.flatten(3))
        expect(Normalize.to_array(@nested_array, flatten: -1)).to match_array(@nested_array.flatten(-1))
      end

      it 'does not flatten the array if "flatten:" is an invalid value' do
        expect(Normalize.to_array(@nested_array, flatten: 'abc')).to match_array(@nested_array)
        expect(Normalize.to_array(@nested_array, flatten: 0.5)).to match_array(@nested_array)
        expect(Normalize.to_array(@nested_array, flatten: nil)).to match_array(@nested_array)
      end
    end
  end

  describe 'from_array' do
    it 'Returns the first element of the array if it contains only one element' do
      expect(Normalize.from_array(['abc'])).to match('abc')
    end

    it 'returns the original array if it contains more than one element' do
      expect(Normalize.from_array(%w[abc def])).to match_array(%w[abc def])
    end

    it 'returns nil if the array is empty' do
      expect(Normalize.from_array([])).to be_nil
    end

    it 'returns what it received if it does not get an array' do
      expect(Normalize.from_array(15)).to eq(15)
    end
  end

  describe 'from_string' do
    it 'converts a string into its representative data type' do
      expect(Normalize.from_string('100')).to eq(100)
    end

    it 'converts number strings into Numerics' do
      expect(Normalize.from_string('0b100')).to eq(0b100)
    end

    it 'converts boolean words to Booleans' do
      expect(Normalize.from_string('true')).to be(true)
    end

    it 'converts words that start with a colon into Symbols' do
      expect(Normalize.from_string(':abc')).to eq(:abc)
    end

    context 'when converting arrays, it calls itself on each element' do
      it 'converts numbers to numerics' do
        expect(Normalize.from_string('[1, 2, 3]')).to eq([1, 2, 3])
      end

      it 'converts booleans' do
        expect(Normalize.from_string('[true, false]')).to match_array([true, false])
      end

      it 'strips whitespace around each element during conversion' do
        expect(Normalize.from_string('[  efg   , abc]')).to match_array(%w[efg abc])
      end

      it 'recursively calls itself on each nested array' do
        expect(Normalize.from_string('[abc, 123]')).to match_array(['abc', 123])
        expect(Normalize.from_string('[1, [false]]')).to match_array([1, [false]])
        expect(Normalize.from_string('[1, [false, [true, 2, b], :sym]]')).to match_array([1,
                                                                                          [false, [true, 2, 'b'],
                                                                                           :sym]])
      end

      it 'converts invalid arrays into strings' do
        expect(Normalize.from_string('[1, 2, 3')).to match('[1, 2, 3')
      end

      it 'corrects arrays with too many commas' do
        expect(Normalize.from_string('[a,,]')).to match_array(['a'])
      end

      it 'accepts escaped closing brackets' do
        expect(Normalize.from_string('[a, one two\]]')).to match_array(['a', 'one two\]'])
      end

      it 'accepts arrays containing strings' do
        expect(Normalize.from_string('["abc", "def"]')).to match_array(%w["abc" "def"])
      end

      it 'cannot handle escaped quotes' do
        expect { Normalize.from_string('["\"abc\""]') }.to raise_error(TypeError)
      end

      it 'returns any invalid data types' do
        expect(Normalize.from_string(13)).to eq(13)
      end
    end
  end
end
