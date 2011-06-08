(function() {
  var loc = window.location,
      pushSupport = !!(window.history && window.history.pushState),
      hashStrip = /^#*/;

  // add HTML5 support to Backbone.history, drop the old IE stuff
  _.extend(Backbone.History.prototype, {
    getFragment : function(l) {
      l = l || window.location;
      if (pushSupport){
        return l.pathname;
      } else {
        return l.hash.replace(hashStrip, '');
      }
    },
    start : function() {
      if (pushSupport) {
        // modern browsers
        $(window).bind('popstate', this.checkUrl);
      } else if('onhashchange' in window) {
        // older browsers without pushState support
        if(loc.pathname === "/"){
          $(window).bind('hashchange', this.checkUrl);
        }else{
          // automatically redirect browsers to the BB-readable path
          var hashPath = "/#" + loc.pathname;
          loc.replace(hashPath);
          return;
        }
      }
      return this.loadUrl();
    },
    saveLocation : function(fragment) {
      fragment = (fragment || '').replace(hashStrip, '');
      if (this.fragment == fragment) return;
      if(pushSupport){
        this.fragment = fragment;
        history.pushState({ts: new Date()}, document.title, loc.protocol + "//" + loc.host + fragment);
      }else{
        window.location.hash = this.fragment = fragment;
      }
    }
  });
})();
