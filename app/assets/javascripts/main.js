// preload locations for Suburb, State, Postcode used by typeaheadjs
var locations;
function init() {
  // preload locations
  locations = new Bloodhound({
    datumTokenizer: function(d) {
      return Bloodhound.tokenizers.whitespace(d.value);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    prefetch: '/locations/suburb_state_postcode.json'
  });

  locations.initialize();
}

// export csv
function export_leads(){
  console.log('exporting leads');
  lead_ids = [];
  $("input.select_lead:checked").each(function(ind, elem){
    lead_ids.push("lead_ids[]=" + $(elem).attr("lead_id"));
  });
  if (lead_ids.length !== 0) {
    export_url = "/leads.csv?" + lead_ids.join('&');
    window.location.href = export_url;
  } else {
    bootbox.alert("Please select lead(s) to export.");
  }
}

function send_notification(notification_type, message) {
  console.log("notification_type: " + notification_type + " message: " + message);
  var type_color = 'danger';
  if (notification_type === 'success')
    type_color = 'primary';
  if (notification_type === 'switch_off')
    type_color = 'success';
  // notification_type = 'success', 'danger'
  // Send notification
  $.niftyNoty({
    type : type_color,
    container : 'floating',
    html : message,
    timer : 5000
  });
}

// Validate email
function validateEmail(email) {
  var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
  return re.test(email);
}

// Jump to anchor
function jump(h){
  //Save down the URL without hash.
  var url = location.href;
  //Go to the target element.
  location.href = "#"+h;
  //Don't like hashes. Changing it back.
  history.replaceState(null,null,url);
}

//selected leads will be highlighted
//TO DO:these two could be merged
function selected(event, isChecked) {
  tag = event.target;
  if(isChecked) {
    $(tag).parents('tr[class^="lead_inspections_"]').css('background-color','#FFFFCC');
  }
  else {
    $(tag).parents('tr[class^="lead_inspections_"]').css('background-color','#FFFFFF');
  }
  isSelectedAll();
}

function allSelected(event, isChecked) {
  tag = event.target;
  if(isChecked) {
    $(tag).parents('#all_leads').find('tr[class^="lead_inspections_"]').css('background-color','#FFFFCC');
  }
  else {
    $(tag).parents('#all_leads').find('tr[class^="lead_inspections_"]').css('background-color','#FFFFFF');
  }
}

//hover effect for email button
function emailHover() {
  $('.email img').mouseenter(function(){
    $(this).prop('src','/assets/email_hover.png');
  }).mouseleave(function(){
    $(this).prop('src','/assets/email.png');
  })
}

init();