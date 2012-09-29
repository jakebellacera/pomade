require 'test_helper'

# Fixtures
$valid_assets = [
  { target: "XX~username", type: :text, value: "jakebellacera"},
  { target: "XX~avatar", type: :image, value: "http://www.gravatar.com/avatar/98363013aa1237798130bc0fd2c4159d.png"}
]

class PublisherTest < Test::Unit::TestCase
  def test_public_authentication
    pom = Pomade::Publisher.new
    assert pom.test_authentication
  end

  def test_asset_validation
    pom = Pomade::Publisher.new

    assert_nothing_raised do
      pom.validate($valid_assets)
    end
  end
end
