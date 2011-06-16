require 'lib/core_extensions/string/anal_title_case'
require 'lib/core_extensions/string/to_valid_utf8'

class String
  include CoreExtensions::String::AnalTitleCase
  include CoreExtensions::String::ToValidUtf8
end