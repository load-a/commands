RSpec.describe Forge do
  describe 'correct settings' do
    it 'is case insensitive for parameters only' do
      test_input = %w[--RUBY type:MAIN TEst]
      forge = Forge.new(test_input)
      forge.run

      expect(forge.modes).to match('--ruby')
      expect(forge.settings[:type]).to match('main')
      expect(forge.parameters).to match('TEst')
    end
  end

  describe 'file orientation' do
    it 'knows where it is' do
      # @todo Figure out a way to make sure the program knows where it's called from
    end
  end
end
