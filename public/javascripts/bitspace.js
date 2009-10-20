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
});