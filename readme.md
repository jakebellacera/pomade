# Pomade - The ruby Pomegranate API wrapper

Pomade is a gem that acts as an API wrapper used for interfacing with TimesSquare2's [Pomegranate API](http://api.timessquare2.com/pomegranate/).

## Installation

Add this line to your application's Gemfile:

    gem 'pomade'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pomade

## Publisher

Publisher lets you publish content to the Pomegranate API.

```ruby
Pomade::Publisher.new(subdomain, username, password, client_id, options)
```

#### Available Options

These are the available options and their defaults.

```ruby
{
    host:           'timessquare2.com',     # [string] The host (domain name) that Pomegranate lives on.
    pathname:       '/p/p.svc/Assets/',     # [string] The path that is used for interacting with Pomegranate.
    time_format:    "%Y-%m-%dT%H:%M:%SZ",   # [string] (strftime) change the layout of the timestamp.
    login_domain:   nil                     # [string] NTLM login domain.
}
```

### Usage

To publish assets to Pomegranate, simply create a new `Pomade::Publisher` instance.

```ruby
@pom = Pomade::Publisher.new('my-subdomain', 'myusername', 'mypassword', 'XX')
```

Next, you'll want to push your assets to Pomegranate. You can do this by building an array of hashes. Each item in the array represents a single asset and they each have three keys: **:target**, **:type** and **:value**. You'll pass this array into the `publish` method.

```ruby
assets = [
  { target: "XX~username", type: :text, value: "jakebellacera"},
  { target: "XX~avatar", type: :image, value: "http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png"}
]

record = @pom.publish(assets)
```

The `publish` method will return a **record**. A record is a hash with two keys: **:record_id** and **:assets**. The `:record_id` is a randomly generated UUID string with your client_id prepended to it while the `:assets` array is the posted assets.

```ruby
puts record
#=>
{
  record_id: "XX-91c8071a-1201-4f99-bc9d-f8d53a947dc1",
  assets: [
    {
      "AssetID" => "9a24c8e2-1066-42fb-be1c-697c5ead476d",
      "AssetData" => "jakebellacera",
      "AssetType" => "TEXT",
      "Target" => "XX~username",
      "Client" => "XX",
      "Status" => "APPROVED",
      "AssetMeta" => "",
      "AssetRecordID" => "XX-91c8071a-1201-4f99-bc9d-f8d53a947dc1"
    },
    {
      "AssetID" => "9a24c8e2-1066-42fb-be1c-697c5ead476d",
      "AssetData" => "http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png",
      "AssetType" => "IMAGE",
      "Target" => "XX~avatar",
      "Client" => "XX",
      "Status" => "APPROVED",
      "AssetMeta" => "",
      "AssetRecordID" => "XX-91c8071a-1201-4f99-bc9d-f8d53a947dc1"
    }
  ]
}
```

#### Validation

Once you attempt to publish your assets, `Publisher` will attempt to validate your assets. Most of the time it will work, as Publisher will check your URLS for :image and :video types and ensure that they resolve properly. This validation may not find everything and you'll still get a bad response from Pomegranate, if that's the case, please [file a bug](http://github.com/jakebellacera/pomade/issues) with the steps you took to reproduce the problem.

## More Info

Need more info? Check the [docs](http://rdoc.info/github/jakebellacera/pomade/master/frames) or [browse the source](http://github.com/jakebellacera/pomade).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
