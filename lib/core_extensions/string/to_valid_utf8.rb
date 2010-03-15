module CoreExtensions
  module String
    module ToValidUtf8
      
      def to_valid_utf8
        valid_strings = ['UTF-8', 'ISO 8859-1'].map do |encoding|
          ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
          valid_string = ic.iconv(self)
        end
        valid_strings.sort_by {|s| s.length }.first
      end
      
    end
  end
end