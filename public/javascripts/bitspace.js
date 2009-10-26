$(function(){
  if(Shadowbox) {
    Shadowbox.init({ skipSetup: true });
    Shadowbox.setup();
  }
  
  $.address.change(function(e){
    $('#page').load(e.value, null, function(){
      var links = $('#page a[rel*=shadowbox]');
      if(links.length) {
        Shadowbox.setup(links);
      }
    });
  });
  
  $('a[target=_self]').livequery('click', function(e){
    e.preventDefault();
    $.address.value($(this).attr('href'));
  });
  
  $('#menu a').livequery('click', function(e){
    e.preventDefault();
    $('#menu a').removeClass('current');
    $(this).addClass('current');
    $.address.value($(this).attr('href'));
  });
  
  $('a[rel=play]').livequery('click', function(e){
    e.preventDefault();
    var playlist = [];
    $(this).add($(this).closest('li').nextAll().find('a[rel=play]')).each(function(){
      var self = $(this);
      playlist.push(function(){
        $('audio#player').trigger('start', self.attr('href'));
        $('#status-artist').text(self.attr('data-artist'));
        $('#status-track').text(self.attr('data-track'));
        $('#status-release').text(self.attr('data-release'));
        $('#status').fadeIn('slow');
        $('.playing').removeClass('playing').removeClass('loading');
        self.addClass('playing');
      });
    });
    $('audio#player').queue('playlist', playlist).trigger('next');
  });
  
  $('button[rel=play-pause]').livequery('click', function(e){
    e.preventDefault();
    $('audio#player').trigger('toggle');
  });
  
  $('button[rel=next]').livequery('click', function(e){
    e.preventDefault();
    $('audio#player').trigger('next');
  });
  
  $('#nav-progress').each(function(){
    var progress = $(this);
    var gauge = progress.find('.gauge');
    var player = $('#player');
    setInterval(function(){
      var percent = ((player.get(0).currentTime / player.get(0).duration) * 100);
      gauge.width(percent+'%');
    }, 300);
  });
  
  $('audio#player')
  .bind('start', function(e,data){
    this.src = data;
    this.load();
    this.play();
  })
  .bind('play', function(e){
    $('button[rel=play-pause]').addClass('pause').attr('disabled','');
  })
  .bind('pause', function(e){
    $('button[rel=play-pause]').removeClass('pause');
  })
  .bind('toggle', function(e){
    if(this.paused) { this.play(); } else { this.pause(); }
  })
  .bind('ended', function(e){
    if($(this).queue('playlist').length == 0) {
      $('button[rel=play-pause]').attr('disabled','disabled');
      $('button[rel=next]').attr('disabled', 'disabled');
      $('#status').fadeOut('slow');
    } else {
      $(this).dequeue('playlist');
    }
  })
  .bind('next', function(e){
    $(this).dequeue('playlist');
    if($(this).queue('playlist').length > 0) {
      $('button[rel=next]').attr('disabled', '');
    } else {
      $('button[rel=next]').attr('disabled', 'disabled');
    }
  })
  .bind('prev', function(e){
    alert('prev');
  })
  .bind('loadstart', function(e){
    $('a.playing').addClass('loading');
  })
  .bind('canplaythrough', function(e){
    $('a.loading').removeClass('loading');
  });

});