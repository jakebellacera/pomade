require "securerandom"
require "ntlm/http"
require "nokogiri"

module Pomade
  class Publisher
    # Public: Creates a new instance of Publisher that pushes records to
    # Pomegranate.
    # 
    # Parameters: 
    #
    #   subdomain - [string] The subdomain for the Pomegranate instance that 
    #               you'd like to connect to.
    #   username  - [string] The username used for connecting to your instance.
    #   password  - [string] The password used for connecting to your instance.
    #   client_id - [string] Your client ID.
    #   opts      - [hash] (optional) Additional options.
    # 
    #   Available options are:
    #   host        - [string] The host (domain name) that Pomegranate lives on.
    #   pathname    - [string] The path that is used for interacting with
    #                 Pomegranate.
    #   time_format - [string] (strftime) change the layout of the timestamp
    #   domain      - [string] NTLM login domain.
    #   debug       - [boolean] Turns on debug mode. This will print out
    #                 any activity.
    # 
    # Returns:
    # 
    #   Returns an instance of Pomade::Publisher
    # 
    # Example:
    # 
    #   @pom = Pom.new('my-subdomain', 'myusername', 'mypassword', 'XX')
    def initialize(subdomain, username, password, client_id, opts = {})
      @subdomain = subdomain
      @username = username
      @password = password
      @client_id = client_id

      # Other options
      @options = {}
      @options[:host] = opts[:host] || 'timessquare2.com'
      @options[:pathname] = opts[:pathname] || '/p/p.svc/Assets/'
      @options[:time_format] = opts[:time_format] || "%Y-%m-%dT%H:%M:%SZ"
      @options[:domain] = opts[:domain] || nil
      @options[:debug] = opts[:debug] || false
    end

    # Public: Publishes an array of assets to Pomegranate
    # 
    # Parameters:
    # 
    #   assets - [array] A collection of assets. Each item consits of a hash with
    #            three keys: { target: "", type: "", value: "" }
    # 
    # Returns:
    # 
    #   A hash containing two keys: record_id and assets.
    # 
    # Example:
    # 
    #   records = [
    #     { target: "XX~USERNAME", type: "TEXT", value: "jakebellacera"},
    #     { target: "XX~AVATAR", type: "IMAGE", value: "http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png"}
    #   ]
    #   @pom.publish(records)
    #   #=> {
    #         record_id: "XX-91c8071a-1201-4f99-bc9d-f8d53a947dc1",
    #         assets: [
    #           {"AssetID"=>"9a24c8e2-1066-42fb-be1c-697c5ead476d", "AssetData"=>"jakebellacera", "AssetType"=>"TEXT", "Target"=>"NS~USERNAME", "Client"=>"XX", "Status"=>"APPROVED", "AssetMeta"=>"", "AssetRecordID"=>"XX-91c8071a-1201-4f99-bc9d-f8d53a947dc1"},
    #           {"AssetID"=>"9a24c8e2-1066-42fb-be1c-697c5ead476d", "AssetData"=>"http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png", "AssetType"=>"IMAGE", "Target"=>"XX~Avatar", "Client"=>"XX", "Status"=>"APPROVED", "AssetMeta"=>"", "AssetRecordID"=>"XX-91c8071a-1201-4f99-bc9d-f8d53a947dc1"}
    #         ]
    #       }
    def publish(assets)
      puts "Available options: #{@options}" if @options[:debug]
      @time = Time.now.strftime(@options[:time_format])
      @record_id = generate_record_id

      xmls = []
      assets.each do |r|
        xmls << build_xml(@record_id, r[:target], r[:type].upcase, r[:value])
      end

      return {
        record_id: @record_id,
        assets: post(xmls)
      }
    end

    # Public: Generates a record ID
    #
    # Parameters:
    # 
    #   None
    #
    # Returns:
    # 
    #   Returns a string containing the client_id with a UUID appended to it.
    def generate_record_id
      @client_id + '-' + SecureRandom.uuid
    end

    private

    def post(data)
      response_data = []
      data.each do |xml|
        puts xml if @options[:debug]

        req = send_request(xml)

        if req[:code] == "201"
          puts "===> SUCCESS!" if @options[:debug]
          response_data << req[:data]
        else
          if req[:code] == "401"
            # TODO: Tell user that we couldn't authenticate
            puts "===> ERROR! Authentication" if @options[:debug]
          elsif req[:code] == "400"
            # TODO: Tell the user there was a formatting error
            puts "===> ERROR! Formatting" if @options[:debug]
          else
            # TODO: Tell the user an unknown error has occured
            puts "===> ERROR Unknown" if @options[:debug]
          end
          response_data = false
          break
        end
      end

      response_data
    end

    def send_request(body)
      status = false
      data = false
      code = ""

      puts "Initializing request for #{@subdomain + '.' + @options[:host]}" if @options[:debug]
      Net::HTTP.start("#{@subdomain}.#{@options[:host]}", 80) do |http|
        req = Net::HTTP::Post.new(@options[:pathname])

        req.content_type = 'application/atom+xml'
        req.content_length = body.size - 20 # Currently a bug with the Pomegranate API I believe
        req.body = body
        req.ntlm_auth(@username, @options[:domain], @password)

        response = http.request(req)
        puts response.inspect if @options[:debug]

        code = response.code

        if code == "201"
          data = parse_xml(response.body)
        else
          break
        end
      end

      {:code => code, :data => data}
    end

    def build_xml(record_id, target, type, value)
      <<-EOF.gsub(/^ {8}/, '')
        <?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
        <entry
          xml:base="/p/p.svc/"
          xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices"
          xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata"
          xmlns="http://www.w3.org/2005/Atom">
          <id></id>
          <title type="text"></title>
          <updated>#{@time}</updated>
          <author><name /></author>
          <category term="pomegranateModel.Asset" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme" />
          <content type="application/xml">
            <m:properties>
              <d:AssetID>--</d:AssetID>
              <d:AssetData>#{value}</d:AssetData>
              <d:AssetType>#{type}</d:AssetType>
              <d:AssetMeta></d:AssetMeta>
              <d:AssetRecordID>#{record_id}</d:AssetRecordID>
              <d:Target>#{target}</d:Target>
              <d:Client>#{@client_id}</d:Client>
              <d:Status>APPROVED</d:Status>
            </m:properties>
          </content>
        </entry>
      EOF
    end

    def parse_xml(xml)
      parsed_xml = Nokogiri::XML(xml.gsub(/\n|\r|  /, ""))
      data = {}
      parsed_xml.css('m|properties').children.each do |p|
        data[p.name] = p.content
      end
      data
    end
  end
end
