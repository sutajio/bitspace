module AWS
  module S3
    class Connection
      UNSAFE_URI = Regexp.new(URI::REGEXP::UNSAFE.source.sub(/\+/,''),false,'N').freeze
  
      def self.prepare_path(path)
        path = path.remove_extended unless path.valid_utf8?
        URI.escape(path,UNSAFE_URI)
      end
    end
  end
end