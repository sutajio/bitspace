
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
    dataType:     API_HOST ? 'jsonp' : 'json',
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
      artist: { name: 'Unknown Artist' },
      label: { name: 'Unknown Label' },
      year: null,
      release_date: null,
      small_artwork_url: null,
      medium_artwork_url: null,
      large_artwork_url: null,
      original_artwork_url: null,
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
    },
    match: function(query) {
      if(query == null || query == '') { return true; }
      if(this.get('title') && this.get('title').toLocaleLowerCase().indexOf(query.toLocaleLowerCase()) != -1) { return true; }
      if(this.get('artist') && this.get('artist').name.toLocaleLowerCase().indexOf(query.toLocaleLowerCase()) != -1) { return true; }
      if(this.get('label') && this.get('label').name.toLocaleLowerCase().indexOf(query.toLocaleLowerCase()) != -1) { return true; }
      return false;
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
    },
    subscribe: function(channel_name) {
      this.channel = pusher.subscribe(channel_name);
      this.channel.bind('add', _.bind(function(release) {
        this.add([release]);
        this.sort();
      }, this));
      this.channel.bind('update', _.bind(function(release) {
        var r = this.get(release.id || release._id);
        if(r) { r.set(release); }
      }, this));
      this.channel.bind('remove', _.bind(function(release) {
        var r = this.get(release.id || release._id);
        if(r) { this.remove(r); }
      }, this));
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
      _.bindAll(this, 'render', 'addRelease', 'removeRelease');
      this.collection.bind('refresh', this.render);
      this.collection.bind('remove', this.removeRelease);
    },
    render: function() {
      $(this.el).empty();
      if(this.collection.length > 0) {
        this.collection.forEach(_.bind(function(release){
          if(release.match(this.query)) {
            this.addRelease(release);
          }
        }, this));
      } else {
        $(this.el).html(this.template({}));
      }
      return this;
    },
    addRelease: function(release) {
      var view = new ReleaseItemView({ model: release, id: "release-"+release.id });
      $(this.el).append(view.el);
    },
    removeRelease: function(release) {
      $(this.el).find('#release-'+release.id).remove();
    },
    filterWith: function(query) {
      this.query = query;
      this.render();
    }
  });

  window.AppView = Backbone.View.extend({
    el: $('body'),
    template: _.template($('#app-template').html()),
    events: {
      'click #header nav a': 'loadPage',
      'keydown #search-query': 'processSearchKey',
      'click #search button': 'performSearch'
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
    showReleasesList: function(r, options) {
      var options = _.defaults(options || {}, { refresh: true });
      this.releasesList = new ReleasesListView({ collection: r }).render();
      $('#content').empty();
      $(window).scrollTop(0);
      if(options.refresh) {
        $('#loading').show();
        r.fetch({
          success: _.bind(function() {
            $('#loading').hide();
            $('#content').empty().append(this.releasesList.el);
          }, this),
          error: function() { $('#loading').hide(); alert('Error'); }
        });
      } else {
        $('#content').append(this.releasesList.el);
      }
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
    performSearch: function(e) {
      if(e) { e.preventDefault(); }
      var query = this.searchQuery.val();
      if(this.releasesList) {
        this.releasesList.filterWith(query);
      }
    }
  });

  window.Controller = Backbone.Controller.extend({
    routes: {
      '/': 'home',
      '/popular': 'popular',
      '/newest': 'newest',
      '/:profile': 'profile'
    },
    home: function() {
      app.showReleasesList(releases, { refresh: releases.length == 0 });
      $('#header nav a').removeClass('current');
      $('#header nav a#home').addClass('current');
    },
    profile: function(profile) {
      var profileReleases = new Releases([]);
      profileReleases.url = '/'+profile+'/releases';
      app.showReleasesList(profileReleases);
      $('#header nav a').removeClass('current');
    },
    popular: function() {
      app.showReleasesList(popularReleases);
      $('#header nav a').removeClass('current');
      $('#header nav a#popular').addClass('current');
    },
    newest: function() {
      app.showReleasesList(newestReleases);
      $('#header nav a').removeClass('current');
      $('#header nav a#newest').addClass('current');
    }
  });

});
