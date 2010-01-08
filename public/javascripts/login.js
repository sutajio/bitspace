$(function(){
  
  $('.field input').inputHint({ using: '+kbd' });
  
  $('#reset-password-form').validate({
    rules: { password: { required: true, minlength: 4 } }
  });
  
});