RSpec.describe Forge do
  before :all do
    @test_name = 'spec_test'
    @temp_dir = "#{Dir.home}/temp_dir"
    Dir.mkdir @temp_dir
  end

  it 'has Make and Remove modes' do
    expect(Forge.new.options.keys).to match_array %i[make remove]
  end

  it 'is case sensitive for settings and parameters' do
    expect(Forge.new[:case_sensitivity]).to match_array %i[parameters configurations]
  end

  describe 'File Orientation:' do
    it 'has both an execution and send directory' do
      expect(Forge.new[:execution_directory]).to_not be_nil
      expect(Forge.new[:send_directory]).to_not be_nil
    end

    it 'can change its send directory' do
      send_to = 'default_folder'
      expect(Forge.new(['send_directory:default_folder'])[:send_directory]).to match send_to
    end

    it 'cannot change its execution directory' do
      run_at = 'dangerous_folder'
      expect(Forge.new(['execution_directory:default_folder'])[:execution_directory]).not_to match run_at
    end
  end

  describe 'File Creation and Deletion:' do
    before :all do
      @file_name = @test_name + '.txt'
      @file_path = "#{@temp_dir}/#{@file_name}"
      @forge = Forge.new([@file_name, "send_directory:#{@temp_dir}"])
    end

    it 'uses the correct send directory' do
      expect(@forge[:send_directory]).to match @temp_dir
    end

    it 'crates files' do
      @forge.generate_file
      expect(File).to exist(@file_path)
    end

    it 'deletes files' do
      @forge.remove_file
      expect(File).to_not exist(@file_path)
    end
  end

  after :all do
    Dir.rmdir @temp_dir
  end
end
