module CoreExtensions
  module String
    module AnalTitleCase
      CLOSED_CLASS_WORDS = %w(the of a and is are on by or in our)
      
      def anal_title_case
        res = self.titleize
        CLOSED_CLASS_WORDS.each do |word|
          res = res.gsub(" #{word.titleize} ", " #{word} ")
        end
        res
      end
    end
  end
end