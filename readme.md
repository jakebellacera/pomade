# Pomade - The ruby Pomegranate API wrapper

![Build Status](https://secure.travis-ci.org/jakebellacera/pomade.png)

Pomade is a ruby library that acts as an API wrapper used for interfacing with TimesSquare2's [Pomegranate API](http://api.timessquare2.com/pomegranate/).

## Installation

Add this line to your application's Gemfile:

    gem 'pomade', '~> 0.2.2'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pomade

## Publisher

_View the full documentation [here](http://rdoc.info/github/jakebellacera/pomade/master/Pomade/Publisher)_

Publisher lets you easily publish content to the Pomegranate API. It handles everything from authenticating your requests to building XML files, so all you need to worry about is the content.

```ruby
@pom = Pomade::Publisher.new

assets = [
  { target: "PUB~1text", type: :text, value: "jakebellacera" },
  { target: "PUB~1image", type: :image, value: "http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png" }
]

record = @pom.publish(assets)

puts record
# =>
{
  record_id: "P0-91c8071a-1201-4f99-bc9d-f8d53a947dc1",
  assets: [
    {
      "AssetID" => "9a24c8e2-1066-42fb-be1c-697c5ead476d",
      "AssetData" => "jakebellacera",
      "AssetType" => "TEXT",
      "Target" => "PUB~1text",
      "Client" => "P0",
      "Status" => "UPLOADED",
      "AssetMeta" => "",
      "AssetRecordID" => "P0-91c8071a-1201-4f99-bc9d-f8d53a947dc1"
    },
    {
      "AssetID" => "9a24c8e2-1066-42fb-be1c-697c5ead476d",
      "AssetData" => "http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png",
      "AssetType" => "IMAGE",
      "Target" => "PUB~1image",
      "Client" => "P0",
      "Status" => "UPLOADED",
      "AssetMeta" => "",
      "AssetRecordID" => "P0-91c8071a-1201-4f99-bc9d-f8d53a947dc1"
    }
  ]
}
```

### Usage

To publish assets to Pomegranate, simply create a new Publisher instance (for available options, [go here](http://rdoc.info/github/jakebellacera/pomade/master/Pomade/Publisher:initialize)).

```ruby
@pom = Pomade::Publisher.new
```

Next, you'll need to publish your assets. An asset is a `hash` that consists of three keys: **:target**, **:type** and **:value**.

```ruby
assets = [
  { target: "PUB~1text", type: :text, value: "jakebellacera" },
  { target: "PUB~1image", type: :image, value: "http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png" }
]

record = @pom.publish(assets)
```

Once the publishing is complete, Publisher will return the finalized record data.

```ruby
puts record
# =>
{
  record_id: "P0-91c8071a-1201-4f99-bc9d-f8d53a947dc1",
  assets: [
    {
      "AssetID" => "9a24c8e2-1066-42fb-be1c-697c5ead476d",
      "AssetData" => "jakebellacera",
      "AssetType" => "TEXT",
      "Target" => "PUB~1text",
      "Client" => "P0",
      "Status" => "UPLOADED",
      "AssetMeta" => "",
      "AssetRecordID" => "P0-91c8071a-1201-4f99-bc9d-f8d53a947dc1"
    },
    {
      "AssetID" => "9a24c8e2-1066-42fb-be1c-697c5ead476c",
      "AssetData" => "http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png",
      "AssetType" => "IMAGE",
      "Target" => "PUB~1image",
      "Client" => "P0",
      "Status" => "UPLOADED",
      "AssetMeta" => "",
      "AssetRecordID" => "P0-91c8071a-1201-4f99-bc9d-f8d53a947dc1"
    }
  ]
}
```

#### Authentication

If you require authentication, you can authenticate either at initialization or by running the `authenticate` method. Publisher will attempt to authenticate with Pomegranate. Since this is a setter method, you can authenticate as many times as you'd like throughout your application.

```ruby
credz = {
  username: "myuser",
  password: "mypass",
  subdomain: "mysubdomain",
  client_id: "XX"
}
@pom.authenticate(opts)
# => true
```

#### Validation

Once you attempt to publish your assets, Publisher will attempt to validate your assets. Most of the time it will work, as Publisher will check your URLS if the asset's type is :image and :video and ensure that they resolve properly. This validation may not find everything and you'll still get a bad response from Pomegranate. If that's the case, please [file a bug](http://github.com/jakebellacera/pomade/issues) with the steps you took to reproduce the problem.

You can also run a validation manually by running the `validate(assets)` method where `assets` is your array of assets to check against.

## More Info

Need more info? Check the [docs](http://rdoc.info/github/jakebellacera/pomade/master/frames) or [browse the source](http://github.com/jakebellacera/pomade).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
