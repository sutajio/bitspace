ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :defaults => [
    '/vendor/jquery/jquery.js',
    '/vendor/swfobject/swfobject.js',
    '/vendor/swfupload/swfupload.js',
    '/vendor/plugins/jquery.swfupload.js',
    'bitspace'
  ])
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
  :defaults => [
    'reset', 'text', 'grid', 'bitspace'
  ])
