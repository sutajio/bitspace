$(function(){
  $('a[rel=play]').livequery('click', function(e){
    e.preventDefault();
    $('#player').attr('src', this.href).each(function(){ this.load(); this.play(); });
    $('.playing').removeClass('playing');
    $(this).addClass('playing');
  });
  
  $('a[rel=pause]').livequery('click', function(e){
    e.preventDefault();
    $('#player').each(function(){ if(this.paused) { this.play(); } else { this.pause(); } });
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
  
  $('a.cover-art[rel=shadowbox]').livequery('click', function(e){
    e.preventDefault();
    Shadowbox.open({ content: this.href, player: 'img' });
  });
});