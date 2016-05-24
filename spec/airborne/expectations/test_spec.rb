require 'airborne'

describe 'sample spec' do
  it 'should validate types' do
    mock_get('simple_get', 'Content-Type' => 'application/json')
    get '/simple_get'
    expect_json_types(name: :string)
    expect_json_types(age: :int)
    expect_json_types(address: :string_or_null)
    # the above can be combined as following
    expect_json_types(name: :string, age: :int_or_null, address: :string_or_null)

  end

  it 'should validate values' do
    mock_get('simple_get', 'Content-Type' => 'application/json')
    get '/simple_get'
    # expect_json(name: 'John Doe') this will fail
    expect_json(name: 'Alex')
    expect_json(name: regex('^A'))
    # expect_json(name: -> (name){expect(name.length).to eq(8)}) this will fail as Alex has the length of 4
    expect_json(name: -> (name){expect(name.length).to eq(4)})
  end

  it 'should return the correct json size' do
    mock_get('array_of_types', 'Content-Type' => 'application/json')
    get '/array_of_types'
    expect_json_sizes(array_of_ints: 3)
  end

  # this still fails
  it 'should allow optional nested hash' do
    mock_get('simple_nested_path', 'Content-Type' => 'application/json')
    get '/simple_nested_path' # may or maynot return coordinates
    # expect_json_types('address.coordinates', optional(latitude: :float, longitude: :float))
    expect_json_keys([:name, :address])
    expect_json_keys('address', [:street, :city, :state, :coordinates])
    expect_json_types('address', street: :string, city: :string, state: :string, coordinates: :object)
    # expect_json('address.coordinates', latitude: 33.3872, longitude: 104.5281)
    #or this
    # expect_json_types('address', street: :string, city: :string, state: :string, coordinates: {latitude: :float, longitude: :float })
  end

  it 'should index into array and test against specific element' do
    mock_get('array_with_index', 'Content-Type' => 'application/json')
    get '/array_with_index'
    expect_json('cars.0', make: 'Tesla', model: 'Model S')
    expect_json('cars.?', make: 'Tesla', model: 'Model S') # tests that one car in array matches the tesla
    expect_json_types('cars.*', make: :string, model: :string) # tests all cars in array for make and model of type string
  end

  it 'should check all nested arrays for specified elements' do
    mock_get('array_with_nested', 'Content-Type' => 'application/json')
    get '/array_with_nested'
    expect_json_types('cars.*.owners.*', name: :string) # * and ? work for nested arrays as well
  end

  it 'should verify date type' do
    mock_get('date_response', 'Content-Type' => 'application/json')
    get '/date_response' #api that returns {createdAt: "Mon Oct 20 2014 16:10:42 GMT-0400 (EDT)"}
    # JSON has no support for dates, however airborne gives you the ability to check for dates using the following
    expect_json_types(createdAt: :date)

    # if you want to check the actual date data with expect_json, you need to call the date function:
    prev_date = DateTime.new(2014,10,19)
    next_date = DateTime.new(2014,10,21)

    # within the date callback, you can use regular RSpec expectations that work with dates
    expect_json(createdAt: date {|value| expect(value).to be_between(prev_date, next_date)})
  end
  end