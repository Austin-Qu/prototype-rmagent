// Send notification
$.niftyNoty({
  type : "<%= @notification_type %>",
  container : 'floating',
  html : "<%= @message %>",
  timer : 3000
});
// Close reset password dropdown 
if ("<%= @notification_type %>" === "success") {
  $('.dropdown-menu.reset_password form').reset(); 
  $('.dropdown-toggle.reset_password').dropdown('toggle');
}
