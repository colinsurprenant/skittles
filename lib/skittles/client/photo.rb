require 'uri'
require 'net/http/post/multipart'

module Skittles
  class Client
    # Define methods related to photos.
    # @see http://developer.foursquare.com/docs/photos/photos.html
    module Photo
      # Get details of a photo.
      #
      # @param id [String] The id of the photo to retrieve additional information for.
      # @return [Hashie::Mash] A complete photo object.
      # @requires_acting_user Yes
      # @see http://developer.foursquare.com/docs/photos/photos.html
      def photo(id)
        get("photos/#{id}").photo
      end
      
      # Allows users to add a new photo to a checkin, tip, or a venue in
      # general.
      #
      # @param file [String] Path to the file to upload.
      # @param options [Hash] A customizable set of options.
      # @option options [String] checkinId The id of a checkin owned by the user.
      # @option options [String] tipId The ID of a tip owned by the user.
      # @option options [String] venueId The ID of a venue, provided only when adding a public photo of the venue in general, rather than a private checkin or tip photo using the parameters above.
      # @option options [String] broadcast Whether to broadcast this photo to twitter, facebook or both.
      # @option options [String] ll Latitude and longitude of the user's location.
      # @option options [Decimal] llAcc Accuracy of the user's latitude and longitude, in meters.
      # @option options [Decimal] alt Altitude of the user's location, in meters.
      # @option options [Decimal] altAcc Vertical accuracy of the user's location, in meters.
      # @return [Hashie::Mash] The photo that was just created.
      # @requires_acting_user Yes
      # @see http://developer.foursquare.com/docs/photos/add.html
      def add_photo(file, options = {})
        options.merge!({
          :file => UploadIO.new(file, 'image/jpeg', 'image.jpg'),
          :oauth_token => access_token
        })
        uri = URI.parse("#{endpoint}/photos/add")
        File.open(file) do
          req = Net::HTTP::Post::Multipart.new(uri.path, options)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true if uri.scheme == 'https'
          resp = http.start do |net|
            net.request(req)
          end
          
          case resp.code.to_i
          when 200..299
            return Skittles::Utils.parse_json(resp.body).response.photo
          when 400..599
            Skittles::Utils.handle_foursquare_error(resp)
          end
        end
      end
    end
  end
end