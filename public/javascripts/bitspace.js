$(function(){
  if(Shadowbox) {
    Shadowbox.init({ skipSetup: true });
    Shadowbox.setup();
  }
  
  $.address.change(function(e){
    $('#page').load(e.value);
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
  

});