require 'securerandom'

describe 'Fission::Assets::Store' do
  before do
    require 'fission-assets'
    @store = Fission::Assets::Store.new(:provider => :local, :bucket => '/tmp/fission-assets')
    @content = 20.times.map{ SecureRandom.uuid }.join("\n")
    @file = Tempfile.new('fission-asset-test')
    @file.write @content
    @file.rewind
    @key = SecureRandom.uuid
  end

  it 'creates new objects' do
    @store.put(@key, @file).must_equal true
  end

  it 'retrieves objects into tempfile' do
    @store.put(@key, @file).must_equal true
    result = @store.get(@key)
    result.is_a?(Tempfile)
    result.read.must_equal @content
  end
end
