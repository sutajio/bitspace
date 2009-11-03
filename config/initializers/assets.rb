ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :defaults => [
    '/vendor/jquery/jquery.js',
    '/vendor/swfobject/swfobject.js',
    '/vendor/plugins/jquery.livequery.js',
    '/vendor/plugins/jquery.address.js',
    '/vendor/plugins/jquery.shortkeys.js',
    '/vendor/plugins/jquery.infinitescroll.js',
    '/vendor/plugins/jquery.ui.js',
    '/vendor/plugins/jquery.form.js'
  ],
  :upload => [
    '/vendor/swfupload/swfupload.js',
    '/vendor/plugins/jquery.swfupload.js'
  ],
  :shadowbox => [
    '/vendor/shadowbox/shadowbox.js'
  ],
  :application => [
    'bitspace'
  ])
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
  :defaults => [
    'reset', 'text', 'grid'
  ],
  :shadowbox => [
    '/vendor/shadowbox/shadowbox.css'
  ],
  :application => [
    'widgets',
    'layout',
    'bitspace'
  ])
