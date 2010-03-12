$(function(){
  // Initialize Shadowbox.
  if(Shadowbox) {
    Shadowbox.init({ skipSetup: true });
    Shadowbox.setup();
  }
  
  // Handle Ajax error in a nice way.
  $.ajaxSetup({
    error: function(xhr, status, error){
      $('#page').fadeTo('fast', 1);
      switch(status) {
        case 'error':
          $('#error').text('Error ' + 
            (xhr.status == 0 ? ' - Connection lost' : xhr.status)).append(
            $('<div/>').append(xhr.responseText)
          ).fadeIn('slow');
        break;
        case 'timeout':
          $('#error').text('Error - Connection timed out').fadeIn('slow');
        break;
      }
    }
  });
  
  // Hide the error message when it is clicked.
  $('#error').click(function(e){
    $(this).fadeOut('slow');
  });
  
  // Handle change in hashtag URL. Loads the new page and does setup of
  // Shadowbox and current playing track, etc...
  $.address.change(function(e){
    $('#error').fadeOut();
    $('#page').fadeTo('fast', 0.25);
    $.infinitescroll.currPage = 1;
    $.infinitescroll.loadingImg = undefined;
    $.infinitescroll.loadingMsg = undefined;
    $.infinitescroll.container = undefined;
    $.infinitescroll.currDOMChunk = null;
    $.infinitescroll.isDuringAjax = false;
    $.infinitescroll.isInvalidPage = false;
    $.infinitescroll.isDone = false;
    $(window).unbind('scroll.infscr');
    $('#page').load(e.value == '/' ? '/dashboard' : e.value, null, function(){
      $('#page').fadeTo('slow', 1);
      $(window).scrollTop(0);
      var links = $('#page a[rel*=shadowbox]');
      if(links.length) {
        Shadowbox.setup(links);
      }
      if($('audio#player').attr('paused') == false) {
        $('a[href="'+$('audio#player').attr('src')+'"]').addClass('playing');
      }
    });
    $('a.current').removeClass('current');
    $('a[href="'+e.value.replace(/["]/g, '\\"')+'"]').addClass('current');
  });
  
  // Load all links that has target="_self" with Ajax.
  $('a[target=_self]').livequery('click', function(e){
    e.preventDefault();
    $('#error').fadeOut('slow');
    $.address.value($(this).attr('href'));
  });
  
  // Intinite scroll
  $('.infinite-scroll').livequery(function(){
    $(this).infinitescroll({
      navSelector: '.more',
      nextSelector: '.more',
      itemSelector: 'div.infinite-scroll div.infscr-pages div',
      loadingImg: '/images/black/ajax-loader.gif',
      loadingText: 'Please wait...',
      donetext: '',
      bufferPx: 400
    });
  });
  
  // Links with rel="play" acts as play buttons. Plays the file specified in
  // the links href=".." attribute.
  $('a[rel=play]').livequery('click', function(e){
    e.preventDefault();
    $('#error').fadeOut('slow');
    var playlist = [];
    $(this).closest('ul').find('a[rel=play]').each(function(){
      var self = $(this);
      playlist.push({
        play: function(){
          $('audio#player')
            .trigger('start', self.attr('href'));
          $('#status-artist')
            .text(self.attr('data-artist'))
            .attr('href',self.attr('data-artist-url'));
          $('#status-track')
            .text(self.attr('data-track'))
            .attr('href',self.attr('data-track-url'));
          $('#status-release')
            .text(self.attr('data-release'))
            .attr('href',self.attr('data-release-url'));
          $('#status')
            .fadeIn('slow');
          $('.playing')
            .removeClass('playing')
            .removeClass('loading');
          $('a[href="'+$('audio#player')
            .attr('src')+'"]')
            .addClass('playing');
          if(parseFloat(self.attr('data-length')) > 30.0) {
            this.started_playing = new Date();
            $.post(self.attr('data-now-playing-url'), {});
          }
        },
        scrobble: function(){
          if(parseFloat(self.attr('data-length')) > 30.0) {
            $.post(self.attr('data-scrobble-url'),
                   { started_playing: this.started_playing.toUTCString() });
          }
        }
      });
    });
    var playlist_position = 
      $(this).closest('ul').find('li a[rel=play]').index(this);
    $('audio#player')
      .data('playlist', playlist)
      .data('playlist_position', playlist_position)
      .trigger('playcurrent');
  });
  
  // Buttons with rel="play-pause" acts as play/pause buttons. Triggers the
  // "toggle" event on the audio player.
  $('button[rel=play-pause]').livequery('click', function(e){
    e.preventDefault();
    $('audio#player').trigger('toggle');
  });
  
  // Buttons with rel="next" acts as next buttons. Triggers the
  // "next" event on the audio player.
  $('button[rel=next]').livequery('click', function(e){
    e.preventDefault();
    $('audio#player').trigger('next');
  });
  
  // Buttons with rel="prev" acts as prev buttons. Triggers the
  // "prev" event on the audio player.
  $('button[rel=prev]').livequery('click', function(e){
    e.preventDefault();
    $('audio#player').trigger('prev');
  });
  
  // Apply slider functionality to the playback progress bar. Will seek the
  // audio playback on slide. Disabled by default (when no song is playing).
  $('#nav-progress').slider({
    range: 'min',
    value: 0,
    min: 0,
    max: 100,
    slide: function(e, ui){
      $('audio#player').attr('currentTime', ui.value);
    }
  }).slider('disable');
  
  // The audio player object. Handles playback of the audio files and all
  // related events that can be triggered during that process, like buffering,
  // network errors, etc...
  $('audio#player')
  .bind('start', function(e,data){
    this.src = data;
    this.load();
    this.play();
    $('a[href="'+data+'"]').addClass('playing');
  })
  .bind('play', function(e){
    $('button[rel=play-pause]').addClass('pause').attr('disabled','');
    $('#nav-progress').slider('enable');
  })
  .bind('pause', function(e){
    $('button[rel=play-pause]').removeClass('pause');
  })
  .bind('toggle', function(e){
    if($(this).data('playlist')) {
      if(this.paused) { this.play(); } else { this.pause(); }
    }
  })
  .bind('ended', function(e){
    if($(this).data('playlist')[$(this).data('playlist_position')]) {
      $(this).data('playlist')[$(this).data('playlist_position')].scrobble();
    }
    if($(this).data('playlist_position') ==
      ($(this).data('playlist').length - 1)) {
      if(($('#repeat').attr('checked') == true) ||
         ($('#shuffle').attr('checked') == true)) {
        $(this).trigger('next');
      } else {
        $(this).data('playlist', null);
        $(this).data('playlist_position', null);
        $('#nav-progress').slider('disable').slider('value', 0);
        $('button[rel=play-pause]').attr('disabled','disabled')
                                   .removeClass('pause');
        $('button[rel=next]').attr('disabled', 'disabled');
        $('button[rel=prev]').attr('disabled', 'disabled');
        $('.playing').removeClass('playing');
        $('#status').fadeOut('slow');
      }
    } else {
      $(this).trigger('next');
    }
  })
  .bind('playcurrent', function(e){
    if($(this).data('playlist')[$(this).data('playlist_position')]) {
      $(this).data('playlist')[$(this).data('playlist_position')].play();
    }
    if($(this).data('playlist_position') == 0) {
      if(($('#repeat').attr('checked') == false) &&
         ($('#shuffle').attr('checked') == false)) {
        $('button[rel=prev]').attr('disabled', 'disabled');
      } else {
        $('button[rel=prev]').attr('disabled', '');
      }
    } else {
      $('button[rel=prev]').attr('disabled', '');
    }
    if($(this).data('playlist_position') ==
      ($(this).data('playlist').length - 1)) {
      if(($('#repeat').attr('checked') == false) &&
         ($('#shuffle').attr('checked') == false)) {
        $('button[rel=next]').attr('disabled', 'disabled');
      } else {
        $('button[rel=next]').attr('disabled', '');
      }
    } else {
      $('button[rel=next]').attr('disabled', '');
    }
  })
  .bind('next', function(e){
    if($('#shuffle').attr('checked')) {
      $(this)
        .data('playlist_position', 
          Math.floor(Math.random()*$(this).data('playlist').length))
        .trigger('playcurrent');
    } else {
      if($('#repeat').attr('checked') &&
          ($(this).data('playlist_position') ==
          ($(this).data('playlist').length - 1))) {
        $(this)
          .data('playlist_position', 0)
          .trigger('playcurrent');
      } else {
        $(this)
          .data('playlist_position', $(this).data('playlist_position') + 1)
          .trigger('playcurrent');
      }
    }
  })
  .bind('prev', function(e){
    if($('#shuffle').attr('checked')) {
      $(this)
        .data('playlist_position',
          Math.floor(Math.random()*$(this).data('playlist').length))
        .trigger('playcurrent');
    } else {
      if($('#repeat').attr('checked') &&
        ($(this).data('playlist_position') == 0)) {
        $(this)
          .data('playlist_position', $(this).data('playlist').length - 1)
          .trigger('playcurrent');
      } else {
        $(this)
          .data('playlist_position', $(this).data('playlist_position') - 1)
          .trigger('playcurrent');
      }
    }
  })
  .bind('loadstart', function(e){
    $('a.playing').addClass('loading');
  })
  .bind('canplaythrough', function(e){
    $('a.loading').removeClass('loading');
  })
  .bind('durationchange', function(e){
    $('#nav-progress').slider('option', 'max', this.duration);
  })
  .bind('timeupdate', function(e){
    $('#nav-progress').slider('value', this.currentTime);
  })
  .bind('dataunavailable', function(e){
    window.status = 'Data unavailable';
  })
  .bind('empty', function(e){
    window.status = 'Empty';
  })
  .bind('error', function(e){
    $('a.loading').removeClass('loading');
    switch(this.error.code) {
      case MediaError.MEDIA_ERR_ABORTED:
        $('#error').text('Error - Unable to play track.').fadeIn('slow');
      break;
      case MediaError.MEDIA_ERR_NETWORK:
        $('#error').text('Error - Failed to load the track. ' +
          'Check your internet connection.').fadeIn('slow');
      break;
      case MediaError.MEDIA_ERR_DECODE:
      case MediaError.MEDIA_ERR_SRC_NOT_SUPPORTED:
        $('#error').text('Error - Unable to play track. Either the file is ' +
            ' corrupt or you might need to install a codec for the file type.'
          ).fadeIn('slow');
      break;
    }
  });
  
  // Bind some keyboard shortcuts for easier navigation in the UI:
  //
  //    Space   - Play/pause toggle
  //
  $(document).keydown(function(e){
    if(e.keyCode == 32) {
      if(e.target.tagName != 'INPUT') {
        e.preventDefault();
        $('audio#player').trigger('toggle');
      }
    }
  });
  
  // Handle the submit on the search form by changing the URL using the
  // address plug-in (will update the page with the search results using
  // Ajax).
  $('#search-q')
  .suggest('/search/suggestions')
  .closest('form').submit(function(e){
    e.preventDefault();
    var q = $('#search-q').val();
    if(q != "") {
      $.address.value('/search?q='+q.replace(/ /g,'+'));
    }
  });
  
  // Links with rel="love" acts as toggle buttons that sends a HTTP POST
  // request using Ajax to the URL specified in the links href attribute.
  // If the POST is successful the state of the link is updated to "loved".
  $('a[rel=love]').livequery('click', function(e){
    e.preventDefault();
    var self = $(this);
    $.post(this.href, { '_method': 'put' }, function(){
      self.toggleClass('loved');
    });
  });
  
  // The mute button (is actually a HTML checkbox).
  // Toggles the "muted" attribute in the audio player.
  $('#mute').change(function(e){
    if($(this).attr('checked')) {
      $('audio#player').animate({ volume: 0.2 });
      $(this).next('label').addClass('checked');
    } else {
      $('audio#player').animate({ volume: 1.0 });
      $(this).next('label').removeClass('checked');
    }
  });
  
  // The repeat button (is actually a HTML checkbox).
  // Holds the on/off state for the repeat mode and updates the disabled state
  // for the transport buttons (play/pause/next/prev) in accordance with the
  // current state.
  $('#repeat').change(function(e){
    if($(this).attr('checked')) {
      $(this).next('label').addClass('checked');
      if($('audio#player').data('playlist')) {
        $('button[rel=prev]').attr('disabled', '');
        $('button[rel=next]').attr('disabled', '');
      }
    } else {
      $(this).next('label').removeClass('checked');
      if($('audio#player').data('playlist_position') == 0) {
        $('button[rel=prev]').attr('disabled', 'disabled');
      }
      if($('audio#player').data('playlist_position') ==
        ($('audio#player').data('playlist').length - 1)) {
        $('button[rel=next]').attr('disabled', 'disabled');
      }
    }
  });
  
  // The shuffle button (is actually a HTML checkbox).
  // Holds the on/off state for the shuffle mode.
  $('#shuffle').change(function(e){
    if($(this).attr('checked')) {
      $(this).next('label').addClass('checked');
    } else {
      $(this).next('label').removeClass('checked');
    }
  });
  
  // Hide the upload info bubble when it is clicked and show the upload
  // spinner instead.
  $('#upload-info').click(function(e){
    $(this).fadeOut('slow');
    $('#upload-info-arrow').fadeOut('slow')
    if($(this).hasClass('finished') == false) {
      $('#upload-spinner').fadeIn('slow');
    }
  });
  
  // Hide the upload spinner when it is clicked and show the upload info
  // bubble instead.
  $('#upload-spinner').click(function(e){
    $(this).fadeOut('slow');
    $('#upload-info').fadeIn('slow');
    $('#upload-info-arrow').fadeIn('slow')
  });
  
  // Links with rel=delete acts as delete buttons.
  $('a[rel=delete]').livequery('click', function(e){
    e.preventDefault();
    if(confirm('Are you sure?')) {
      var self = $(this).closest('li').fadeTo('fast', 0.5);;
      $.post(this.href, { '_method': 'delete' }, function(){
        self.closest('li').hide('slow', function(){
          $.address.value('/');
        });
      });
    }
  });
  
  // Links with rel="archive" acts as toggle buttons that sends a HTTP POST
  // request using Ajax to the URL specified in the links href attribute.
  // If the POST is successful the state of the link is updated to "archived".
  $('a[rel=archive]').livequery('click', function(e){
    e.preventDefault();
    var self = $(this);
    $.post(this.href, { '_method': 'put' }, function(){
      self.toggleClass('archived');
    });
  });
  
  // Show nice looking (and above all clear and useful) tooltips for all
  // elements with the class "tooltipped". The tooltip will gravitate towards
  // the most appropriate edge of the element depending on the available
  // surrounding space. It will also have a subtle fade effect to better match
  // the overall feel of the UI.
  $('.tooltipped').livequery(function(){
    $(this).tipsy({ gravity: $.fn.tipsy.autoNS, fade: true });
  });
  
  // Custom validator for validating usernames.
  $.validator.addMethod('username', function(value, element){
    return this.optional(element) || /^[a-z][a-z0-9_]+$/.test(value);
  }, 'Should use only lowercase letters, numbers, and underscore please.');
  
  // Handle validation for the user profile form in the account section.
  // The form submits with Ajax in the submitHandler errors are handled by
  // the global Ajax error handlers.
  $('#account-profile-form').livequery(function(){
    $(this).validate({
      rules: {
        'password': { remote: '/account/valid_password' },
        'user[login]': { rangelength: [3,100],
                         remote: '/users/unique',
                         username: true },
        'user[password]': { minlength: 4 },
        'user[password_confirmation]': { equalTo: '#user_password' }
      },
      messages: {
        'password': { remote: 'Invalid password' },
        'user[login]': { remote: 'Sorry, username has already been taken.' }
      },
      submitHandler: function(form) {
        $(form).ajaxSubmit({
          success: function(){
            $.address.value('/');
          }
        });
      }
    });
  });
  
  $('#biography').livequery(function(){
    $(this).expander({
      slicePoint: 1200,
      expandText: '<span class="small">Read more</span>',
      userCollapseText: '<span class="small">Show less</span>'
    });
  });
  
  $('a[rel=toggle]').livequery('click', function(e){
    $(new RegExp('(#.+)$').exec(this.href)[1]).toggle('fast');
    $(this).toggleClass('enabled');
    e.preventDefault();
  });
  
});