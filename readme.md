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
    login_domain:   nil,                    # [string] NTLM login domain.
    debug:          false                   # [boolean] Turns on debug mode. This will print out any activity.
}
```

### Usage

To publish assets to Pomegranate, simply create a new Publisher instance.

```ruby
@pom = Pomade::Publisher.new('my-subdomain', 'myusername', 'mypassword', 'XX')
```

Next, you'll want to push your assets to Pomegranate. You can do this by building an array of hashes. Each item in the array represents a single asset and they each have three keys: **target**, **type** and **value**. You'll pass this array into the `publisher#push` method.

```ruby
assets = [
    { target: "XX~USERNAME", type: "TEXT", value: "jakebellacera"},
    { target: "XX~AVATAR", type: "IMAGE", value: "http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png"}
]

record = @pom.publish(assets)
```

The `Publisher#publish` method will return a **record**. A record is a hash with two keys: **record_id** and **assets**. The record_id is a randomly generated UUID string with your client_id prepended to it while the assets array is the posted assets. If assets is false, then the records failed to push to Pomegranate.

```ruby
puts record
#=> {
      record_id: "XX-91c8071a-1201-4f99-bc9d-f8d53a947dc1",
      assets: [
        {"AssetID"=>"9a24c8e2-1066-42fb-be1c-697c5ead476d", "AssetData"=>"jakebellacera", "AssetType"=>"TEXT", "Target"=>"NS~USERNAME", "Client"=>"XX", "Status"=>"APPROVED", "AssetMeta"=>"", "AssetRecordID"=>"XX-91c8071a-1201-4f99-bc9d-f8d53a947dc1"},
        {"AssetID"=>"9a24c8e2-1066-42fb-be1c-697c5ead476d", "AssetData"=>"http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png", "AssetType"=>"IMAGE", "Target"=>"XX~Avatar", "Client"=>"XX", "Status"=>"APPROVED", "AssetMeta"=>"", "AssetRecordID"=>"XX-91c8071a-1201-4f99-bc9d-f8d53a947dc1"}
      ]
    }
```

#### Debugging

Sometimes Pomegranate will not be able to accept your request. If you're getting a 400 error, it's most likely a formatting issue. Since the errors returned by Pomegranate are not very verbose, it's best to run through a simple checklist instead:

* Ensure that your login info is correct. You can test in your browser by logging in via HTTPS at `<subdomain>.timessquare2.com`. If you'd like to use cURL or something else, connect via NTLM.
* Make sure that the targets and types for each asset are correct. Targets will vary from client to client.
* Try creating a pomegranate with the `debug` option set to `true` and try again.
* If all else fails, you can try submitting an [issue](https://github.com/jakebellacera/pomade/issues). Please be specific in your bug report.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
