RSpec.describe Object do
  before :all do
    @test_object = Object.new
  end

  describe '#this' do
    it 'returns its own class' do
      expect(@test_object.this).to be(@test_object.class)
      expect(@test_object.this).to be_a(Class)
    end
  end

  describe '#parent' do
    it 'returns its own superclass' do
      expect(@test_object.parent).to be(@test_object.class.superclass)
      expect(@test_object.parent).to be_a(Class)
    end
  end
end
