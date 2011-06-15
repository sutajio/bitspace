
_.templateSettings = {
  interpolate: /\{\{(.+?)\}\}/g,
  evaluate: /\{\%(.+?)\%\}/g
};

var methodMap = {
  'create': 'POST',
  'update': 'PUT',
  'delete': 'DELETE',
  'read'  : 'GET'
};

var getUrl = function(object) {
  if (!(object && object.url)) return null;
  return _.isFunction(object.url) ? object.url() : object.url;
};

var urlError = function() {
  throw new Error("A 'url' property or function must be specified");
};

var secondsToTime = function(seconds) {
  var zeroPad = function(number) {
    if(number < 10) { return "0"+number; } else { return number; }
  };
  if(seconds < 60) {
    return "0:"+zeroPad(seconds);
  } else if(seconds < 3600) {
    return Math.floor(seconds/60)+":"+zeroPad(seconds%60);
  } else {
    return (seconds / 60) + " min";
  }
};

Backbone.emulateJSON = true;

Backbone.sync = function(method, model, success, error) {
  var type = methodMap[method];

  // Default JSON-request options.
  var params = {
    type:         type,
    dataType:     'jsonp',
    processData:  false,
    success:      success,
    error:        error
  };

  // Ensure that we have a URL.
  if (!params.url) {
    var url = getUrl(model) || urlError();
    if(API_HOST) {
      params.url = 'http://' + API_HOST + decodeURI(url);
    } else {
      params.url = decodeURI(url);
    }
  }

  // Ensure that we have the appropriate request data.
  if (!params.data && model && (method == 'create' || method == 'update')) {
    params.contentType = 'application/json';
    params.data = JSON.stringify(model.toJSON());
  }

  // For older servers, emulate JSON by encoding the request into an HTML-form.
  if (Backbone.emulateJSON) {
    params.contentType = 'application/x-www-form-urlencoded';
    params.processData = true;
    params.data        = params.data ? {model : params.data} : {};
  }

  // For older servers, emulate HTTP by mimicking the HTTP method with `_method`
  // And an `X-HTTP-Method-Override` header.
  if (Backbone.emulateHTTP) {
    if (type === 'PUT' || type === 'DELETE') {
      if (Backbone.emulateJSON) params.data._method = type;
      params.type = 'POST';
      params.beforeSend = function(xhr) {
        xhr.setRequestHeader('X-HTTP-Method-Override', type);
      };
    }
  }

  // Make the request.
  return $.ajax(params);
};

$(function(){

  $(document).ajaxError(function(e, jqxhr, settings, exception) {
    alert(jqxhr.status);
  });

  window.Release = Backbone.Model.extend({
    defaults: {
      title: 'Unknown Title',
      artist: 'Unknown Artist',
      year: null,
      artwork: null,
      tracks: []
    },
    initialize: function() {
      _.bindAll(this, 'refreshTracks');
      this.tracks = new Tracks(this.get('tracks'), { comparator: function(t) { return t.get('track_nr'); } });
      this.bind('change:tracks', this.refreshTracks);
    },
    refreshTracks: function() {
      this.tracks.refresh(this.get('tracks'));
    },
    url: function() {
      return '/releases/' + encodeURIComponent(this.id);
    }
  });

  window.Track = Backbone.Model.extend({
    defaults: {
      title: 'Unknown Title',
      artist: null,
      url: null,
      play_count: 0
    },
    play: function() {
      player.start(this.get('url'));
      this.trigger('playing', this);
      $.post('/now_playing', { id: this.get('id') });
    },
    scrobble: function() {
      $.post('/scrobble', { id: this.get('id') });
    }
  });

  window.Tracks = Backbone.Collection.extend({
    model: Track
  });

  window.Releases = Backbone.Collection.extend({
    model: Release,
    parse: function(response) {
      return _.map(response.data || response.releases, function(data){ return _.defaults(data, { id: data._id }); });
    }
  });

  window.ReleaseView = Backbone.View.extend({
    className: 'release',
    template: _.template($('#release-template').html()),
    events: {
      'click .track': 'playTrack'
    },
    initialize: function() {
      _.bindAll(this, 'render', 'renderTracks');
      this.model.bind('change', this.render);
      this.model.tracks.bind('refresh', this.renderTracks);
      player.bind('playing', this.renderTracks);
    },
    render: function() {
      $(this.el).html(this.template(_.extend(this.model.toJSON(), { url: getUrl(this.model) })));
      this.renderTracks();
    },
    renderTracks: function() {
      this.$('.release-tracks ol').empty();
      this.model.tracks.forEach(_.bind(function(track){
        var view = new TrackItemView({ model: track });
        this.$('.release-tracks ol').append(view.el);
      }, this));
    },
    playTrack: function(e) {
      e.preventDefault();
      player
        .setPlaylist(this.model.tracks.models)
        .setPlaylistPosition(this.$('.track').index($(e.srcElement).closest('.track')))
        .playCurrent();
    }
  });

  window.ReleaseItemView = Backbone.View.extend({
    tagName: 'li',
    className: 'release-item',
    template: _.template($('#release-item-template').html()),
    events: {
      'click a': 'flipRelease'
    },
    initialize: function() {
      _.bindAll(this, 'render');
      this.model.bind('change', this.render);
      this.model.bind('playing', this.render);
      this.render();
    },
    render: function() {
      $(this.el).html(this.template(this.model.toJSON()));
      return this;
    },
    flipRelease: function(e) {
      e.preventDefault();
      if(this.releaseView) {
        $(this.el).removeClass('flip');
        this.releaseView = null;
      } else {
        $(this.el).addClass('flip');
        this.releaseView = new ReleaseView({ model: this.model });
        this.releaseView.render();
        $(this.el).find('.back').empty().append(this.releaseView.el);
      }
    }
  });

  window.TrackItemView = Backbone.View.extend({
    tagName: 'li',
    className: 'track',
    template: _.template($('#track-item-template').html()),
    initialize: function() {
      _.bindAll(this, 'render', 'showLoading');
      this.model.bind('change', this.render);
      this.model.bind('playing', this.showLoading);
      this.render();
    },
    render: function() {
      $(this.el).html(this.template(this.model.toJSON()));
      if(this.model && player.currentTrack() &&
         this.model.get('url') == player.currentTrack().get('url')) {
        $(this.el).addClass('playing');
      }
      return this;
    },
    showLoading: function() {
      $('li.track').removeClass('loading').removeClass('playing');
      $(this.el).addClass('loading');
    }
  });

  window.ReleasesListView = Backbone.View.extend({
    tagName: 'ol',
    className: 'releases-list',
    template: _.template($('#fallback-template').html()),
    initialize: function() {
      _.bindAll(this, 'render', 'addRelease');
      this.collection.bind('refresh', this.render);
      this.collection.bind('add', this.addRelease);
    },
    render: function() {
      $(this.el).empty();
      if(this.collection.length > 0) {
        this.collection.forEach(_.bind(function(release){
          this.addRelease(release);
        }, this));
      } else {
        $(this.el).html(this.template({}));
      }
      return this;
    },
    addRelease: function(release) {
      var view = new ReleaseItemView({ model: release });
      $(this.el).append(view.el);
    }
  });

  window.AppView = Backbone.View.extend({
    el: $('body'),
    template: _.template($('#app-template').html()),
    events: {
      'click #header nav a': 'loadPage',
      'keypress #search-query': 'processSearchKey',
      'blur #search-query': 'hideSearch',
      'click #search-query': 'performSearch'
    },
    initialize: function() {
      _.bindAll(this, 'render');
    },
    render: function() {
      $(this.el).html(this.template({}));
      this.searchQuery = this.$('#search-query');
      return this;
    },
    loadPage: function(e) {
      e.preventDefault();
      var href = $(e.currentTarget).attr('href');
      Backbone.history.saveLocation(href);
      Backbone.history.loadUrl();
    },
    processSearchKey: function(e) {
      if(/27$|38$|40$/.test(e.keyCode) ||
         /^13$|^9$/.test(e.keyCode)) {
        if(e.preventDefault)
          e.preventDefault();
        if(e.stopPropagation)
          e.stopPropagation();
        e.cancelBubble = true;
        e.returnValue = false;
      } else if (this.searchQuery.val().length != this.prevSearchQueryLength) {
        _.delay(_.bind(function(){
          this.performSearch();
        }, this), 100);
        this.prevSearchQueryLength = this.searchQuery.val().length;
      }
    },
    performSearch: function() {
      if(this.searchQuery.val() != '') {
        var query = this.searchQuery.val();
        var comparator = function(x,y) {
          return x.toLocaleLowerCase().indexOf(y.toLocaleLowerCase());
        };
        var results = this.model.collections.select(function(collection){
          return comparator(collection.get('name') || collection.get('title'), query) != -1;
        });
        results = _.sortBy(results, function(collection){
          return comparator(collection.get('name') || collection.get('title'), query);
        });
        if(results.length > 0) {
          this.searchResults.updateResults(results).show();
        }
      }
    },
    hideSearch: function() {
      setTimeout(_.bind(function() { this.searchResults.hide() }, this), 200);
    }
  });

  window.Controller = Backbone.Controller.extend({
    routes: {
      '/': 'home',
      '/:profile/': 'profile',
      '/popular': 'popular',
      '/newest': 'newest'
    },
    home: function() {
      var releasesList = new ReleasesListView({ collection: releases }).render();
      $('#content').empty();
      $('#header nav a').removeClass('current');
      $('#header nav a#home').addClass('current');
      $('#loading').show();
      $(window).scrollTop(0);
      releases.fetch({
        success: function() {
          $('#loading').hide();
          $('#content').empty().append(releasesList.el);
        },
        error: function() { alert('Error'); }
      });
    },
    profile: function(profile) {
      var profileReleases = new Releases([]);
      profileReleases.url = '/'+profile+'/releases';
      var releasesList = new ReleasesListView({ collection: profileReleases }).render();
      $('#content').empty();
      $('#header nav a').removeClass('current');
      $('#loading').show();
      $(window).scrollTop(0);
      profileReleases.fetch({
        success: function() {
          $('#loading').hide();
          $('#content').empty().append(releasesList.el);
        },
        error: function() { alert('Error'); }
      });
    },
    popular: function() {
      var releasesList = new ReleasesListView({ collection: popularReleases }).render();
      $('#content').empty();
      $('#header nav a').removeClass('current');
      $('#header nav a#popular').addClass('current');
      $('#loading').show();
      $(window).scrollTop(0);
      popularReleases.fetch({
        success: function() {
          $('#loading').hide();
          $('#content').empty().append(releasesList.el);
        },
        error: function() { alert('Error'); }
      });
    },
    newest: function() {
      var releasesList = new ReleasesListView({ collection: newestReleases });
      $('#content').empty();
      $('#header nav a').removeClass('current');
      $('#header nav a#newest').addClass('current');
      $('#loading').show();
      $(window).scrollTop(0);
      newestReleases.fetch({
        success: function() {
          $('#loading').hide();
          $('#content').empty().append(releasesList.el);
        },
        error: function() { alert('Error'); }
      });
    }
  });

});
