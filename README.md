# Fission Assets

Simple API to store and retrieve objects.

## Usage

```ruby

require 'fission-assets/store'

object_store = Fission::Assets::Store.new
object = object_store.get('item/i/want.json')

File.open('/tmp/fubar', 'w') do |f|
  f.write object.read
  f.puts 'YAY'
end

object_store.put('my/updated/file.json', '/tmp/fubar')
```

## Configuration

Configure via fission JSON

```json
{
  :fission => {
    :assets => {
      :provider => 'AWS', # or 'local'
      :connection => {
        ... fog compat args ...
      },
      :bucket => 'BUCKET_NAME'
    }
  }
}
```