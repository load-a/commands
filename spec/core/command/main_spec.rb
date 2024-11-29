RSpec.describe Command do
  before(:all) do
    @random_flags = %w[-a -b -c --something --random --question]
    @random_keywords = %w[one:1 two:2 bool:true thing:something]
    @random_parameters = %w[file.exe something.txt cool_game_title]
    @file_type_input = %w[-c kind:text source/file.rb destination/folder]
    @random_input = %w[-abc+ --asdf key:val kees:bat arigatou thanks]
    @default_input = %w[-h --help -i --inspect case_sensitive:false]
  end

  describe 'Modes' do
    describe '#options' do
      before do
        @command = Command.new
        @command.options += @random_flags
      end

      it 'lists all available option flags the command accepts' do
        expect(@command.options).to match_array(%w[--help -h --inspect -i] + @random_flags)
      end

      context 'when no new options are specified' do
        it 'returns a list of required options' do
          expect(Command.new.options).to match_array(%w[--help -h --inspect -i])
        end
      end
    end
  end

  describe 'Settings' do
    describe '#keywords' do
      it 'extracts keywords from settings hash' do
        expect(Command.new.settings.keys).to match_array(Command.new.keywords)
      end
    end
  end

  # @todo Describe:
  #   - parameters
  #   - initialization
  #   - error handling (maybe in its own test)
  #   - Directory behavior

  describe 'received inputs' do
    describe '#raw' do
      it 'returns the initial input' do
        expect(Command.new(@random_input).raw).to match_array(@random_input)
        expect(Command.new([]).raw).to be_empty
      end
    end

    describe '#valid' do
      it 'retrieves strings that match certain patterns from @raw' do
        command = Command.new(@random_input)
        expect(command.valid).to be_a Hash
        expect(command.valid[:modes]).to match_array(%w[-abc+ --asdf])
        expect(command.valid[:settings]).to match_array(%w[key:val kees:bat])
        expect(command.valid[:parameters]).to match_array(%w[arigatou thanks])
      end
    end

    describe '#processed' do
      before do
        @command = Command.new(@default_input)
        @command.default_settings[:mode_limit] = (0..4) # The number of modes in this test
        @command.run
      end

      it 'converts @valid inputs that match its own possible inputs into their respective data types' do
        expect(@command.processed).to be_a Hash
        expect(@command.processed[:modes]).to match_array(%w[--help -h --inspect -i])
        expect(@command.processed[:settings]).to include(case_sensitive: false)
        expect(@command.processed[:parameters]).to be_empty
      end

      it 'correctly returns abbreviated values' do
        expect(@command.modes).to match_array(@command.processed[:modes])
        expect(@command.settings).to match(@command.default_settings.merge(@command.processed[:settings]))
        expect(@command.parameters).to be_nil
      end
    end
  end

  # @todo Add the correct results once implemented
  describe 'helper modes' do
    describe '#help' do
      it 'Calls the help screen' do
        expect(Command.new.help).to_not be_nil
      end
    end

    describe '#inspect' do
      it 'Calls the inspect screen' do
        expect(Command.new.inspect).to be_nil
      end
    end
  end

  describe 'run' do
    it 'runs the command' do
      command = Command.new @random_input
      expect(command.run).to_not be_nil
    end
  end
end
