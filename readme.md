# Pomade - The ruby Pomegranate API wrapper

Pomade is a gem that acts as an API wrapper used for interfacing with TimesSquare2's [Pomegranate API](http://api.timessquare2.com/pomegranate/).

## Usage

Installing is easy with Bundler:

    gem 'pomade'

Once the gem is installed and included in your project, you'll need to initialize a `Pomade` object with your connection info and any other options you'd like to specify:

````ruby
@pom = Pomade.new('api_subdomain', 'username', 'password', 'client_id', opts)
#                        ^- = http://[my-subdomain].timessquare2.com
````

### Options

The available options and their defaults are:

````ruby
{
    domain:         'timessquare2.com',     # This string appends to the subdomain
    pathname:       '/p/p.svc/Assets/',     # The path where you send POST requests to
    time_format:    "%Y-%m-%dT%H:%M:%SZ",   # strftime format for sending timestamps
    login_domain:   nil,                    # Optional domain attribute for authenticating via NTLM
    debug:          false                   # Prints debugging output
}
````

### Publishing

Publishing is simple. Create your record you'd like to push. A record has an `id` and a `data` array full of individual assets.

````ruby
@record = {
    id: 1234,
    data: [
        { target: 'NS~TARGETNAME1', type: 'IMAGE', value: 'http://domain.com/images/a.jpg' },
        { target: 'NS~TARGETNAME2', type: 'TEXT', value: 'This is some text.' } 
        { target: 'NS~TARGETNAME3', type: 'VIDEO', value: 'http://domain.com/videos/1.m4v' } 
    ]
}
````

Next, you'll need to tell Pomade to push it up to Pomegranate. You do this with the `publish` method. This method will return all of the created assets in a nice array.

````ruby
response = @pom.publish(@record)

puts response
# => [
#      {"AssetID"=>"9a24c8e2-1066-42fb-be1c-697c5ead476d", "AssetData"=>"http://domain.com/images/a.jpg", "AssetType"=>"IMAGE", "Target"=>"NS~TARGETNAME1", "Client"=>"client_id", "Status"=>"APPROVED", "AssetMeta"=>"", "AssetRecordID"=>"1234"},
#      {"AssetID"=>"9a24c8e2-1066-42fb-be1c-698d5ead476d", "AssetData"=>"This is some text.", "AssetType"=>"TEXT", "Target"=>"NS~TARGETNAME2", "Client"=>"client_id", "Status"=>"APPROVED", "AssetMeta"=>"", "AssetRecordID"=>"1234"}
#      {"AssetID"=>"9a24c8e2-1066-42fb-be1c-698d5ead476d", "AssetData"=>"http://domain.com/videos/1.m4v", "AssetType"=>"VIDEO", "Target"=>"NS~TARGETNAME3", "Client"=>"client_id", "Status"=>"APPROVED", "AssetMeta"=>"", "AssetRecordID"=>"1234"}
# ]
````
