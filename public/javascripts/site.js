$(function(){
  
  if(Shadowbox) {
    Shadowbox.init({ skipSetup: true });
    Shadowbox.setup();
  }
  
  $('#invitation_request_email').inputHint({ hintAttr: 'hint' });
  $('#new_invitation_request').validate();
  
  $('.tooltipped').tipsy({ gravity: 's' });
  $('.save-elsewhere a').tipsy({ gravity: 's' });
  
  $('.biography').livequery(function(){
    $(this).expander({
      slicePoint: 1200,
      expandText: '<span class="small">Read more</span>',
      userCollapseText: '<span class="small">Show less</span>'
    });
  });
  
  $('.review').livequery(function(){
    $(this).expander({
      slicePoint: 450,
      expandText: '<span class="small">Read more</span>',
      userCollapseText: '<span class="small">Show less</span>'
    });
  });
  
});