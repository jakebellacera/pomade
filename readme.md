# Ruby Pomegranate API Wrapper

This is an API wrapper used for interfacing with TimesSquare2's [Pomegranate API](http://api.timessquare2.com/pomegranate/).

## Usage

Installing is easy with Bundler:

    gem 'ruby-pomegranate'

Next, you'll need to initialize a `Pomegranate` object with your connection info and any other options you'd like to specify:

````ruby
@record = {
    id: 1234,
    data: [
        { target: 'NS~TARGETNAME1', type: 'IMAGE', data: 'http://domain.com/images/a.jpg' },
        { target: 'NS~TARGETNAME2', type: 'TEXT', data: 'This is some text.' } 
        { target: 'NS~TARGETNAME3', type: 'VIDEO', data: 'http://domain.com/videos/1.m4v' } 
    ]
}

@pom = Pomegranate.new('api_subdomain', 'username', 'password', 'client_id', opts)
#                            ^- = http://[my-subdomain].timessquare2.com
````

Running the `create` method will return an object containg the hashes of each generated asset's properties in key/value form:

````ruby
# Push it up to Pomegranate!
response = @pom.publish(my_record)

puts response
# => [
#      {"AssetID"=>"9a24c8e2-1066-42fb-be1c-697c5ead476d", "AssetData"=>"http://domain.com/images/a.jpg", "AssetType"=>"IMAGE", "Target"=>"NS~TARGETNAME1", "Client"=>"client_id", "Status"=>"APPROVED", "AssetMeta"=>"", "AssetRecordID"=>"1234"},
#      {"AssetID"=>"9a24c8e2-1066-42fb-be1c-698d5ead476d", "AssetData"=>"This is some text.", "AssetType"=>"TEXT", "Target"=>"NS~TARGETNAME2", "Client"=>"client_id", "Status"=>"APPROVED", "AssetMeta"=>"", "AssetRecordID"=>"1234"}
#      {"AssetID"=>"9a24c8e2-1066-42fb-be1c-698d5ead476d", "AssetData"=>"http://domain.com/videos/1.m4v", "AssetType"=>"VIDEO", "Target"=>"NS~TARGETNAME3", "Client"=>"client_id", "Status"=>"APPROVED", "AssetMeta"=>"", "AssetRecordID"=>"1234"}
# ]
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
