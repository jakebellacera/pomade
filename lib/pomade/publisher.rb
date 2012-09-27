require "securerandom"
require "ntlm/http"
require "nokogiri"

module Pomade
  ##
  # Handles all interactions to Pomegranate.
  class Publisher
    ##
    # Creates a new instance of +Publisher+ that pushes records to Pomegranate.
    # 
    # == Parameters
    # 
    # * *subdomain* _(string)_ - The subdomain for the Pomegranate instance that you'd like to connect to.
    # * *username* _(string)_ - The username used for connecting to your isntance.
    # * *password* _(string)_ - The password used for connecting to your isntance.
    # * *client_id* _(string)_ - Your client ID.
    # * *opts* _(hash, optional)_ - Additional options. Available options are:
    #   * *:host* _(string)_ - The host (domain name) that your Pomegranate instance lives on.
    #   * *:pathname* _(string)_ - The path that is used for interacting with assets.
    #   * *:time_format* _(strftime)_ - Change the layout of the timestamp that is posted to your instance.
    #   * *:domain* _(string)_ - NTLM login domain.
    # 
    # == Returns
    # An instance of +Pomade::Publisher+
    # 
    # == Example
    #
    #   @pom = Pomade::Publisher.new('my-subdomain', 'myusername', 'mypassword', 'XX')
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
    end

    ##
    # Publishes an array of assets to Pomegranate and returns the results in a +hash+.
    # 
    # == Parameters
    # 
    # * *assets* _(array)_ - A collection of assets. Each item consists of a hash with three keys: +:target+, +:type+ and +:value+. The values for keys +:target+ and +:value+ are both strings while the +:type+ key's value is a symbol. Available values are:
    #   * +:image+ -- An +IMAGE+ type asset
    #   * +:video+ -- A +VIDEO+ type asset
    #   * +:text+ -- A +TEXT+ type asset
    # 
    # == Returns
    # 
    # A +hash+ containing two keys: +record_id+ and +assets+.
    # 
    # == Example
    # 
    #   records = [
    #     { target: "XX~username", type: :text, value: "jakebellacera"},
    #     { target: "XX~avatar", type: :image, value: "http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png"}
    #   ]
    #   
    #   @pom.publish(records)
    #   # =>
    #   {
    #     record_id: "XX-91c8071a-1201-4f99-bc9d-f8d53a947dc1",
    #     assets: [
    #       {
    #         "AssetID" => "9a24c8e2-1066-42fb-be1c-697c5ead476d",
    #         "AssetData" => "jakebellacera",
    #         "AssetType" => "TEXT",
    #         "Target" => "XX~username",
    #         "Client" => "XX",
    #         "Status" => "APPROVED",
    #         "AssetMeta" => "",
    #         "AssetRecordID" => "XX-91c8071a-1201-4f99-bc9d-f8d53a947dc1"
    #       },
    #       {
    #         "AssetID" => "9a24c8e2-1066-42fb-be1c-697c5ead476d",
    #         "AssetData" => "http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png",
    #         "AssetType" => "IMAGE",
    #         "Target" => "XX~avatar",
    #         "Client" => "XX",
    #         "Status" => "APPROVED",
    #         "AssetMeta" => "",
    #         "AssetRecordID" => "XX-91c8071a-1201-4f99-bc9d-f8d53a947dc1"
    #       }
    #     ]
    #   }
    def publish(assets)
      @record_id = generate_record_id
      @time = Time.now.strftime(@options[:time_format])

      # Build our XMLs
      xmls = []
      validate(assets).each do |r|
        xmls << build_xml(r[:target], r[:type].to_s.upcase, r[:value])
      end

      return {
        record_id: @record_id,
        assets: post(xmls)
      }
    end

    ##
    # Validates an array of assets.
    # 
    # == Parameters
    #
    # * *assets* _(array)_ - A collection of assets. Each item consists of a hash with three keys: +:target+, +:type+ and +:value+. The values for keys +:target+ and +:value+ are both strings while the +:type+ key's value is a symbol. Available values are:
    #   * +:image+ -- An +IMAGE+ type asset
    #   * +:video+ -- A +VIDEO+ type asset
    #   * +:text+ -- A +TEXT+ type asset
    #
    # == Returns
    # 
    # The +array+ of assets.
    # 
    # == Example
    # 
    #   records = [
    #     { target: "XX~USERNAME", type: :text, value: "jakebellacera"},
    #     { target: "XX~AVATAR", type: :image, value: "http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png"}
    #   ]
    #   
    #   @pom.validate(records)
    #   # =>
    #   [
    #     { target: "XX~USERNAME", type: :text, value: "jakebellacera"},
    #     { target: "XX~AVATAR", type: :image, value: "http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png"}
    #   ]
    def validate(assets)
      available_keys = [:target, :type, :value].sort

      assets.each do |a|
        raise InvalidAssetKeys, "Each asset should only contain the keys: :target, :type, and :value." unless (a.keys & available_keys).sort == available_keys
        raise InvalidAssetType, "Invalid asset type. Available choices are: :text, :image and :video." unless [:text, :image, :video].include?(a[:type])
        test(a)
      end
    end

    private

    ##
    # Generates a +SecureRandom.uuid+ (GUID) with the +client_id+ appended to it.
    def generate_record_id
      @client_id + '-' + SecureRandom.uuid
    end

    ##
    # Tests to see if an asset's +:value+ is correct in correlation to its +:type+.
    def test(asset)
      # If the value is a URL...
      if (asset[:type] == :image || asset[:type] == :video) && url?(asset[:value])
        raise BadAssetValueURL, "Please make sure your asset's value is a valid, working URL." unless Net::HTTP.get_response(URI(asset[:value])).code.to_i == 200
      else
        # Since the value was not a URL, we should raise an error for any IMAGE and VIDEO types.
        raise BadImageValue, "assets with an :image type should have an image URL as the value." if asset[:type] == :image
        raise BadVideoValue, "assets with a :video type should have a video URL as the value." if asset[:type] == :video
      end
    end

    ##
    # Posts an XML to the Pomegranate instance and handles the response.
    #
    # *Note:* This method will fail if any requests are rejected.
    #
    # == Parameters
    # 
    # * *body* _(string, XML)_ - A Pomegranate XML asset
    #
    # == Returns
    # 
    # An +array+ of comiled Pomegranate assets
    def post(data)
      response_data = []
      data.each do |xml|
        req = send_request(xml)

        if req[:code].to_i.between?(200, 201)
          response_data << req[:data]
        else
          if req[:code] == "401"
            raise ResponseError, "Could not authenticate with the Pomegranate API. Ensure that your credentials are correct."
          elsif req[:code] == "400"
            raise ResponseError, "Bad asset value formatting. Please reformat and try again."
          else
            raise StandardError, "An unknown error has occured."
          end
          response_data = false
          break
        end
      end

      response_data
    end

    ##
    # Sends a request to Pomegranate
    #
    # == Parameters
    # 
    # * *body* _(string, XML)_ - A Pomegranate XML asset
    def send_request(body)
      status = false
      data = false
      code = ""

      Net::HTTP.start("#{@subdomain}.#{@options[:host]}", 80) do |http|
        req = Net::HTTP::Post.new(@options[:pathname])

        req.content_type = 'application/atom+xml'
        req.content_length = body.size - 20 # Currently a bug with the Pomegranate API I believe
        req.body = body
        req.ntlm_auth(@username, @options[:domain], @password)

        response = http.request(req)

        code = response.code

        if code == "201"
          data = parse_xml(response.body)
        else
          break
        end
      end

      {:code => code, :data => data}
    end

    ##
    # Builds a Pomegranate asset XML file
    def build_xml(target, type, value)
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
              <d:AssetData>#{type === "TEXT" ? escape_xml(value) : value}</d:AssetData>
              <d:AssetType>#{type}</d:AssetType>
              <d:AssetMeta></d:AssetMeta>
              <d:AssetRecordID>#{@record_id}</d:AssetRecordID>
              <d:Target>#{target}</d:Target>
              <d:Client>#{@client_id}</d:Client>
              <d:Status>APPROVED</d:Status>
            </m:properties>
          </content>
        </entry>
      EOF
    end

    ##
    # Escapes any illegal XML characters
    def escape_xml(string)
      string.gsub!("&", "&amp;")
      string.gsub!("<", "&lt;")
      string.gsub!(">", "&gt;")
      string.gsub!("'", "&apos;")
      string.gsub!("\"", "&quot;")

      return string
    end

    ##
    # Parses XMLs and returns a hash
    def parse_xml(xml)
      parsed_xml = Nokogiri::XML(xml.gsub(/\n|\r|  /, ""))
      data = {}
      parsed_xml.css('m|properties').children.each do |p|
        data[p.name] = p.content
      end
      data
    end

    ##
    # Tests if a string is a URL
    def url?(string)
      begin
        uri = URI.parse(string)
        %w( http https ).include?(uri.scheme)
      rescue URI::BadURIError
        false
      rescue URI::InvalidURIError
        false
      end
    end
  end
end
