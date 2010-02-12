ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :common => [
    '/vendor/jquery/jquery.js',
    '/vendor/plugins/jquery.livequery.js',
    '/vendor/plugins/jquery.form.js',
    '/vendor/plugins/jquery.tipsy.js',
    '/vendor/plugins/jquery.input-hint.js',
    '/vendor/plugins/jquery.validation.js',
    '/vendor/shadowbox/shadowbox.js'
  ],
  :application => [
    '/vendor/swfobject/swfobject.js',
    '/vendor/swfupload/swfupload.js',
    '/vendor/swfupload/swfupload.queue.js',
    '/vendor/plugins/jquery.swfupload.js',
    '/vendor/plugins/jquery.shortkeys.js',
    '/vendor/plugins/jquery.infinitescroll.js',
    '/vendor/plugins/jquery.ui.js',
    '/vendor/plugins/jquery.address.js',
    '/vendor/plugins/jquery.suggest.js',
    'application'
  ],
  :login => [
    'login'
  ],
  :site => [
    'site'
  ])
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
  :common => [
    'common/reset',
    'common/text',
    'common/grid',
    'common/widgets',
    'common/layout',
    '/vendor/shadowbox/shadowbox.css'
  ],
  :application => [
    'application'
  ],
  :login => [
    'login'
  ],
  :site => [
    'site'
  ])
