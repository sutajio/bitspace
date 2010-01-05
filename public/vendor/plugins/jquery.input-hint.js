/*
 * (c) 2008-9 Jason Frame
 * Auxiliary element code based on work by pjesi (http://wtf.hax.is/)
 */
(function($){$.fn.inputHint=function(b){b=$.extend({hintClass:'hint',hintAttr:'title'},b||{});function hintFor(a){var h;if(b.using&&(h=$(b.using,a)).length>0){return h.text()}else{return $(a).attr(b.hintAttr)||''}}function showHint(){if($(this).val()==''){$(this).addClass(b.hintClass).val(hintFor(this))}}function removeHint(){if($(this).hasClass(b.hintClass))$(this).removeClass(b.hintClass).val('')}this.filter(function(){return!!hintFor(this)}).focus(removeHint).blur(showHint).blur();this.each(function(){var a=this;$(this).parents('form').submit(function(){removeHint.apply(a)})});return this.end()}})(jQuery);