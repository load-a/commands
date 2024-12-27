RSpec.describe Command do
  before :all do
    @command = Command.new %w[--bypass argument]
  end

  describe 'Operation' do
    it 'initializes' do
      expect(@command).to_not be_nil
    end

    it 'takes initial input' do
      expect(@command.mode).to be(:bypass)
      expect(@command.parameters).to match_array(%w[argument])
    end

    it 'updates with new input' do
      @command.update_from_input(%w[--inspect])

      expect(@command.mode).to eq(:inspect)
      expect(@command.state[:modes]).to match_array(%i[inspect])

      @command.update_from_input(%w[--bypass argument])
    end
  end

  describe 'Modes' do
    it 'generates a list of mode options' do
      expect(@command.options).to be_a Hash
      expect(@command.options).to_not be_empty
    end

    it 'generates a list of mode flags' do
      expect(@command.flags).to be_a Array
      expect(@command.flags).to_not be_empty
    end

    it 'changes functionality based on the current mode' do
      @command.update_from_input(['--help'])

      expect(@command.run).to_not be_nil
    end
  end

  describe 'ModeHandler Module' do
    it 'runs ModeHandler' do
      expect(Command.new.options).to_not be_nil
    end
  end
end
