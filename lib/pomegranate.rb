require 'ntlm/http'
require 'nokogiri'

class Pomegranate
  def initialize(subdomain, username, password, client_id, opts = {})
    @subdomain = subdomain
    @username = username
    @password = password
    @client_id = client_id

    # Other options
    @options = {}
    @options[:domain] = opts[:domain] || 'timessquare2.com'
    @options[:pathname] = opts[:pathname] || '/p/p.svc/Assets/'
    @options[:time_format] = opts[:time_format] || "%Y-%m-%dT%H:%M:%SZ"
    @options[:login_domain] = opts[:login_domain] || nil
    @options[:debug] = opts[:debug] || false
  end

  def publish(record)
    # You should set up a record like this:
    # { :id, :data => [ {:target, :type, :value}, ... ] }
    puts "Available options: #{@options}" if @options[:debug]
    @time = Time.now.strftime(@options[:time_format])

    xmls = []
    record[:data].each do |r|
      xmls << build_xml(record[:id], r[:target], r[:type], r[:value])
    end

    post(xmls)
  end

  private

  def post(data)
    response_data = []
    data.each do |xml|
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

    puts "Initializing request for #{@subdomain + '.' + @options[:domain]}" if @options[:debug]
    Net::HTTP.start("#{@subdomain}.#{@options[:domain]}", 80) do |http|
      req = Net::HTTP::Post.new(@options[:pathname])

      req.content_type = 'application/atom+xml'
      req.content_length = body.size - 20 # Currently a bug with the Pomegranate API I believe
      req.body = body
      req.ntlm_auth(@username, @options[:login_domain], @password)

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
    <<-EOF.gsub(/^ {6}/, '')
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
