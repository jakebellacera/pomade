module Pomade
  # Errors thrown from Pomegranate
  class ResponseError < StandardError; end

  # If an asset's keys do not match up
  class InvalidAssetKeys < StandardError; end

  # If an asset's type is invalid
  class InvalidAssetType < StandardError; end

  # If a URL's response is not OK
  class BadAssetValueURL < StandardError; end

  # If an :image asset's value is not a valid URL
  class InvalidImageValue < StandardError; end

  # If an :video asset's value is not a valid URL
  class InvalidVideoValue < StandardError; end
end
