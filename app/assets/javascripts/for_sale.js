console.log('in for_sale.js');
function init_for_sale() {
  console.log("in init_for_sale");
  
  // init all bootstap editable fields 
  enable_bootstrap_editable();

  // color box for email/property files auto setting
  $("a.ipad_email_auto_setting.inline").colorbox({
    inline: true, 
    width: "850px",
    height: "660px",
    overlayClose: false,
    onOpen: function(event) {
      $('#runtime').attr('ipad_setting_open', 1);
    },
    onClosed: function(event){
      console.log('onclosed..');
      console.log(event.el);
      console.log('ipad setting set to 0 in colobox');
      $('#runtime').attr('ipad_setting_open', 0);
      if ($('#runtime').attr('ipad_setting_temp_close') === "1") {
        $('a.upload_files.inline').click();
      }
      ins_id = $(this).attr('inspection_id');
      //$('#runtime').attr('inspection_id',ins_id);
      render_inspection(ins_id);
      // detail_open = 'a.inspection_leads_' + ins_id;
      // console.log(detail_open);
      // setTimeout(function(){$(detail_open).click();},300);
    }
  });

  // color box for bulk email
  $("a.bulk_email.inline").colorbox({
    inline:true,
    width: "850px",
    height: "680px",
    overlayClose: false,
    onOpen: function(event) {
      $('i.email_sending').addClass('fa-paper-plane').removeClass('fa-spinner fa-pulse');
      $('button.bulk-send').removeAttr('disabled');
      $('#runtime').attr('bulk_email_open', 1);
      // validate added email
      $('input[id^=recipients_]').on('itemAdded', function(event) {
        email = event.item;
        console.log(email);
        if ( !validateEmail(email) ) {
          send_notification('error','Invalid email');
          $('.bootstrap-tagsinput span.tag.label:last').addClass('btn-danger');
        }
      });

    },
    onClosed: function(event){
      $('#runtime').attr('bulk_email_open', 0);
      if ($('#runtime').attr('bulk_email_temp_close') === "1") {
        $('a.upload_files.inline').click();
        // Save emails to cookie
        emails = [];
        $.each($('span.recipients div.bootstrap-tagsinput span.tag'), function(idx, elem){
          email = $.trim($(elem).text());
          emails.push(email);
        });
        $.cookie('emails', emails.join(','));
      }
      // Deregister email validation
      $('input[id^=recipients_]').unbind('itemAdded');
    },
    onComplete: function(event){
      // prefill recipients
      checked = $('input[type=checkbox][inspection_id=' + inspection_id + ']:checked');
      $('#colorbox input#recipients_' + inspection_id).tagsinput('removeAll');
      if ($.cookie('emails') !== undefined) {
        $.each($.cookie('emails').split(','), function(idx, email){
          console.log(email);
          $('#colorbox input#recipients_' + inspection_id).tagsinput('add', email);
        });
        $.removeCookie('emails');
      } else {
        $.each(checked, function(i, checked_lead){
          email = $(checked_lead).attr('email');
          $('#colorbox input#recipients_' + inspection_id).tagsinput('add', email);
        });      
      }
    }

  });

  // color box for file upload
  $("a.upload_files.inline").colorbox({
    inline:true,
    width: "850px",
    height: "400px",
    overlayClose: false,
    onClosed: function(event){
      console.log('onclosed..');
      console.log(event.el);
      // inspection_id = $(this).attr('inspection_id');
      inspection_id = $('#runtime').attr('inspection_id');
      console.log("inspection_id: " + inspection_id);
      console.log($('#runtime').attr('ipad_setting_open'));
      render_inspection(inspection_id);
      if ($('#runtime').attr('ipad_setting_temp_close') === "1") {
        // closed temporarily as it's closed by upload file
        setTimeout(function(){
          $("a.ipad_email_auto_setting.inline[inspection_id=" + inspection_id + "]").colorbox.close();
          $("a.ipad_email_auto_setting.inline[inspection_id=" + inspection_id + "]").click();
          // $('#runtime').attr('ipad_setting_temp_close', 0);
        }, 500);
      }
      if ($('#runtime').attr('bulk_email_temp_close') === "1") {
        // closed temporarily as it's closed by upload file
        setTimeout(function(){
          $("a.bulk_email.inline[inspection_id=" + inspection_id + "]").colorbox.close();
          $("a.bulk_email.inline[inspection_id=" + inspection_id + "]").click();
          $('#runtime').attr('bulk_email_temp_close', 0);
        }, 500);
      }
    },
    onOpen: function(event) {
      console.log('opening... file upload '); 
      $("a.upload_files.inline").removeClass('current');
      $(this).addClass('current');
      inspection_id = $('#runtime').attr('inspection_id');
      console.log("inspection_id: " + inspection_id);
      init_plupload(inspection_id);
    }
  });

  // color box for image upload
  $("a.upload_image.inline").colorbox({
    inline:true,
    width: "850px",
    height: "400px",
    overlayClose: false,
    onClosed: function(event){
      console.log('upload_image onclosed..');
      inspection_id = $('#runtime').attr('inspection_id');
      render_inspection(inspection_id);
    },
    onOpen: function(event) {
      console.log('upload_image opening'); 
      inspection_id = $('#runtime').attr('inspection_id');
      init_plupload_image(inspection_id);
    }
  });

  // colorbox for listing website: TBD in further versions
  // $("a.list_url").colorbox({
  //   inline: true, 
  //   width: "850px",
  //   height: "660px",
  //   overlayClose: false,
  //   onOpen: function(event) {
  //     console.log('listwebsite opening'); 
  //     //inspection_id = $('#runtime').attr('inspection_id');
  //   }
  // })

  //keep listing website dropdown open when editing
  keep_dropdown();

  //change leads status icons
  status_icon_change();

  //check if listing website is empty
  check_empty_website();

  // multiselect property files in ipad email setting form
  $('select.email_template_property_files').multiselect({
    maxHeight: 200,
    numberDisplayed: 0
  });

  // multiselect property files in bulk email form
  $('select.bulk_email_files').multiselect({
    maxHeight: 200,
    numberDisplayed: 0
  });

  // image overlay
  $('img.property_images').parent().parent().mouseover(function(){
    $(this).find('.image_overlay').show();
  }).mouseout(function (){
    $(this).find('.image_overlay').hide();
  });
  $('.image_overlay').mouseover(function(){
    $(this).show();
  }).mouseout(function (){
    $(this).hide();
  });

  $(document).bind('cbox_complete', function(){
    $('#colorbox select#email_template_template_type').val('File Send');
    $('span.notification').html('');
    $('#colorbox select#email_template_template_type').trigger('change');
  });

  $('select[name="property_files[]"]').next().addClass('dropup');

  //when manually changing status via dropdown button, change the icon.
  $("tr[class^='lead_inspections_']").find(".followup_type").bind("DOMSubtreeModified",function(){
    status_icon_change();
  });

  //inspection status editable layout change
  // $("a[id^='status_']").on('shown', function(e, editable) {
  //   var tag_s = e.target;
  //   $(tag_s).parent().css({'padding':'0px',
  //   'border':'none','background':'none'
  //   });
  //     console.log(e.target);
  //     //$(editable).parents('sale_status').css('padding','0px');
  // }).on('save', function(e, params) {
  //   var tag_s = e.target;
  //   $(tag_s).parent().css({'padding':'6px 17px',
  //   'border':'1px solid #d9e5f7','background-color':'#fafafa'});

  // });

  //change property iamge label
  label_change();

  //switch
  $.fn.bootstrapSwitch.defaults.size = 'mini';
  $('input[id="auto_send"]').bootstrapSwitch();
  $('input[id="auto_send"]').on('switchChange.bootstrapSwitch', function(event, state) {
    $(this).attr('checked',state);
    console.log("switched");
  })


  //$('input[id="auto_send_outside"]').attr({'data-size':'normal'});
  //$('input[id="auto_send_outside"]').bootstrapSwitch();
  $('input.auto_send_outside').attr({'data-size':'normal'});
  $('input.auto_send_outside').bootstrapSwitch({
    onSwitchChange: function(event, state){
      console.log('onSwitchChange...');
      tag = event.target;
      ins_id = $(tag).parents('.single_inspection').attr('inspection_id');
      if (state === true) {
        send_notification('success','The auto-send mail function for current listing is on.');
      }
      else 
        send_notification('switch_off','The auto-send mail function for current listing is off.');

      console.log(ins_id);
      $.ajax({
        method: "GET",
        url: "/inspections/ajax_update.json",
        data: { 'name': 'send_file', 'pk': ins_id, 'value': state }
      })
      .done(function( data ) {
        console.log("switched");
        //inspection_id = data['inspection_id'];

        render_inspection(ins_id);
        detail_open = 'a.inspection_leads_' + ins_id;
        setTimeout(function(){$(detail_open).click();},500);
      });
    }
  });

  //disable action button for listings without lead
  // $('.lead_placeholder').each(function(index,element) {
  //   $(element).parents('.single_inspection').find('#on_sale_types').addClass('disabled');
  // });


  //$("input[class^='property_images']").change(function(event) {
  //  $(this).parent().submit();
  //});

  // typeahead in bulk email  Disabed for Beta for now
  $('_input[id^=recipients_]').tagsinput({
    typeahead: {
      name: 'leads',
      displayKey: 'name',
      valueKey: 'email',
      maxChars: 100,
      source: function(query) {
        d = $.get('/inspections/get_leads_emails_by_user.json?user_id=' + user_id);
        // return d.readyState;
        d = [{"name": "Tony Zhao","email": "tony@zhao.com"}];
        console.log(d);
        return d;
      }
    },
    maxChars: 50
  });

  // date calendar, not used for now
  // $('.filter_date').datepicker({
  //   format: 'yyyy-mm-dd'
  // })
  //   .on('changeDate', function(e){
  //     filter_form = $($(this).closest('form')[0]);
  //     // submit form as JS in javascript
  //     submit_button = $(filter_form.children('input[type=submit]')[0]);
  //     submit_button.click();
  //     $('.filter_date').datepicker('hide');
  //   })
  // ;

  //to do: display font-awesome icons in editable area
  // $('.inspection_item tbody tr td:nth-child(2)').mouseover(function (){
  //   $(this).next('.inspection_item_line1 i').css('display','inline-block');
  // }).mouseout(function (){
  //   $(this).next('.inspection_item_line1 i').css('display','none');
  // });

  isRealEmpty();

  //check empty filter and hide placeholder
  isNodata();

  //re-color selected attendees after rendering inspection
  colorSelected();

  //check select_all when all leads selected
  isSelectedAll();

  //hover effect for email icon
  emailHover();

  //no icon for empty email
  isEmailEmpty();
}

function enable_bootstrap_editable(){
  console.log('initing enable_bootstrap_editable...');
  //turn to inline mode
  $.fn.editable.defaults.mode = 'inline';
  $.fn.editable.defaults.showbuttons = false;
  $.fn.editable.defaults.ajaxOptions = {type: "GET"};
  $.fn.editable.defaults.onblur = "submit";
  //$.fn.editable.defaults.activate = "select";
  $.fn.editable.defaults.success = function(response, newValue) {
    if(response.status == 'error') return response.msg; //msg will be shown in editable form
  };
  $( "a[id^='street_address']" ).editable();

  // locaitons is initialised in main.js
  $( "a[id^='suburb_state_postcode']" ).editable({
    //value:'Type here',
    typeahead: ({
      hint: false
    },
    {
      displayKey: 'value',
      source: locations.ttAdapter(),
      prefetch: {url: '/locations/suburb_state_postcode.json'}
    })
  });
  $( "a[id^='suburb_state_postcode']" ).on('save', function(e, params) {
    if (params.response["updated?"] === false) {
      // Set newValue to origal if submitValue is empty
      params.newValue = params.response[$(this).attr("id")];
    }
  });

  $( "a[id^='listing_url']" ).editable({
    mode: 'popup',
    showbuttons: 'right',
    onblur: 'cancel',
    validate: function(value) {
      if($.trim(value).indexOf("http://") !== 0 && $.trim(value).indexOf("https://") !== 0) {
        return 'Please enter a URL starts with http:// or https://';
      }
    }
  });
  // $( "a[id^='status']" ).editable({
  //   source: on_types
  // });
  $( "a[id^='offer_price']" ).editable();
  $( "a[id^='memo']" ).editable();

}

// render single inspection in js
function render_inspection(inspection_id) {
  on_type = $('.current_on_type').attr('on_type');
  console.log('in render_inspection, inspection_id: ' + inspection_id + ' on_type: ' + on_type);
  selected_inspection_leads = $('input.select_lead[inspection_id=' + inspection_id + ']:checked');
  selected_inspection_lead_ids = [];
  $.each(selected_inspection_leads, function(idx, item){
    selected_inspection_lead_ids.push($(item).attr('inspection_lead_id'));
  });
  console.log('selected_inspection_lead_ids: ' + selected_inspection_lead_ids);
  $.ajax({
    type: "POST",
    url: '/inspections/render_inspection', 
    data: {"inspection_id": inspection_id, "on_type": on_type, "selected_inspection_lead_ids": selected_inspection_lead_ids},
    dataType: "script"
  }).success(function(data){
    console.log("success");
  });
}

// render inspections panel heading in js
function render_panel_heading() {
  on_type = $('.current_on_type').attr('on_type');
  $.ajax({
    type: "POST",
    url: '/inspections/render_panel_heading', 
    data: {"on_type": on_type},
    dataType: "script"
  }).success(function(data){
    console.log("success");
  });
}

// update current on type on page, useful when tab switching in ajax way to get the updated on_type
function update_current_on_type(on_type) {
  $('.current_on_type').attr('on_type', on_type);
}

function click_to_filter_leads(event){
  elem = $(event.target);
  filter_type = elem.attr('filter_type');
  inspection_id = elem.attr('inspection_id');
  var tag = elem.parents('.single_inspection');
  tag.find('#filter_type').val(filter_type).trigger('change');
  //$(this).nextAll(".details").find("a").trigger('click');
  var tag_show = $("tr#inspection_leads_" + inspection_id);
  // var tag_show = elem.nextAll(".details").parents("tr").nextAll("tr#inspection_leads_" + inspection_id);
  console.log('tag_show...');
  console.log(tag_show);
  if (tag_show.hasClass('hide'))
    tag_show.removeClass('hide');
  //var fa = elem.nextAll(".details").find("i"); Not working
  var fa = $('a.inspection_leads_details[inspection_id=' + inspection_id +'] i');
  $(fa).removeClass('fa-chevron-circle-right');
  $(fa).addClass('fa-chevron-circle-down');
  $(fa).closest('tr').addClass('lead_expand');
}

// $('select.filter_type').change(function(event){
function select_filter_type(event){
  elem = $(event.target);
  // filter_form = $($(this).closest('form')[0]);
  filter_form = elem.closest('form');
  inspection_id = filter_form.attr('inspection_id');
  //filter_date = $(filter_form.children('input.filter_date')[0]);
  filter_date = $('input.filter_date[inspection_id=' + inspection_id + ']')
  // submit form as JS in javascript
  val = elem.val();
  // WEB-77
  //if (val === "Inspection Date") {
  //  filter_date.prop('disabled', false);
  //}
  //else {
  //  filter_date.prop('disabled', true);
  //}
  submit_button = $(filter_form.children('input[type=submit]')[0]);
  submit_button.click();

  status_icon_change();
  //console.log("changed");
}

// Remove inspection leads in sub panel
function remove_inspection_leads(event){
  elem = $(event.target);
  inspection_id = $(elem).attr("inspection_id");
  inspection_lead_ids = new Array();
  checked = $('input[type=checkbox][inspection_id=' + inspection_id + ']:checked');
  $.each(checked, function(i, checked_lead){
    inspection_lead_id = $(checked_lead).attr('inspection_lead_id');
    inspection_lead_ids.push(inspection_lead_id);
  });
  if (inspection_lead_ids.length == 0 ) {
    bootbox.alert('Please select attendee(s) to remove from the listing.');
    return;
  }
  bootbox.confirm("Are you sure you want to remove the selected attendee(s) from the current listing? (You can still view and edit the attendee information on the LEADS page)", function(result) {
    if (result === false)
      return;
    $.ajax({
      method: "POST",
      url: "/inspections_leads/delete_inspection_leads",
      dataType: "script",
      data: { inspection_id: inspection_id, inspection_lead_ids: inspection_lead_ids }
    })
      .done(function( data ) {
        send_notification('success', "Delete succeeded");
      })
      .fail(function( data ) {
        send_notification('error', "Delete failed");
      });
  }); 
}

function ipad_settings_upload_files(event){
  console.log('clicked a.ipad_settings_upload_files..');
  // Use jQuery.event.fix(event) to normalise event objects for cross browser support as e.preventDefault() is not supported by IE.
  event = $.event.fix(event); 
  event.preventDefault();
  elem = event.target;
  inspection_id = $(elem).attr('inspection_id');
  console.log('inspection_id: ' + inspection_id);
  $('#runtime').attr('inspection_id', inspection_id);
  console.log('set inspection_id: ' + inspection_id);
  ipad_setting_open = $('#runtime').attr('ipad_setting_open');
  ipad_setting_colorbox = $("a.ipad_email_auto_setting.inline[inspection_id=" + inspection_id + "]");
  if (ipad_setting_open === "1") {
    console.log("ipad_setting_colorbox is open");
    ipad_setting_colorbox.colorbox.close();
    console.log("ipad setting set to 2 after close");
    $('#runtime').attr('ipad_setting_temp_close', 1);
  } else {
    console.log('click to open upload file');
    $('a.upload_files.inline').click();
  }
}

function bulk_email_upload_files(event){
  console.log('clicked a.bulk_email_upload_files..');
  // Use jQuery.event.fix(event) to normalise event objects for cross browser support as e.preventDefault() is not supported by IE.
  event = $.event.fix(event); 
  event.preventDefault();
  elem = event.target;
  inspection_id = $(elem).attr('inspection_id');
  console.log('inspection_id: ' + inspection_id);
  $('#runtime').attr('inspection_id', inspection_id);
  console.log('set inspection_id: ' + inspection_id);
  bulk_email_open = $('#runtime').attr('bulk_email_open');
  bulk_email_colorbox = $("a.bulk_email.inline[inspection_id=" + inspection_id + "]");
  if (bulk_email_open === "1") {
    console.log("bulk_email_colorbox is open");
    bulk_email_colorbox.colorbox.close();
    console.log("bulk email set to 2 after close");
    $('#runtime').attr('bulk_email_temp_close', 1);
  } else {
    console.log('click to open upload file');
    $('a.upload_files.inline').click();
  }
}

//Cancel button closes colorbox
function cancel_colorbox() {
  console.log('cancel ..');
  $('#cboxClose').trigger('click');
}

// delete property files
function delete_property_file(event){
  that = $(event.target);
  bootbox.confirm("Are you sure you want to delete this file?", function(result) {
    if (result === false)
      return;
    that.parent().addClass('hide');
    $.ajax({
      method: "GET",
      url: "/inspections/delete_property_file.json",
      data: { property_file_name: that.attr('property_file_name'), inspection_id: that.attr('inspection_id') }
    })
      .done(function( data ) {
        send_notification('success', data['deleted_property_file'] + " has been deleted");
        inspection_id = data['inspection_id'];
        render_inspection(inspection_id);
      })
      .fail(function( data ) {
        send_notification('error', "Delete failed");
      });
  });
}

// Upload property images
function upload_property_image(event){
  // Use jQuery.event.fix(event) to normalise event objects for cross browser support as e.preventDefault() is not supported by IE.
  event = $.event.fix(event); 
  event.preventDefault();
  elem = event.target;
  inspection_id = $(elem).attr('inspection_id');
  console.log("click: input.property_images_" + inspection_id);
  //$('input.property_images_' + inspection_id).click();
  $('#runtime').attr('inspection_id', inspection_id);
  $('a.upload_image.inline').click();
}

// Update inspection for_sale status
function update_inspection_status(event){
  console.log('clicked inspection status');
  elem = $(event.target);
  inspection_id = elem.attr('inspection_id');
  value = $.trim(elem.text());
  $.ajax({
      type: "GET",
      url: '/inspections/ajax_update.json', 
      data: {"pk": inspection_id, "name": "status", "value": value},
      dataType: "script"
  }).complete(function(jqXHR, textStatus){
    console.log('complete');
    // it seems ruby object to_json may be invalid in javascript. It looks like it's due to null value in json data
    if (jqXHR.status === 227) {
      // 227 is specified in ajax_update in inspections_controller as the succeess return code
      // update status and label
      console.log('updating status and label');
      on_type = $('.current_on_type').attr('on_type');
      render_inspection(inspection_id);
      render_panel_heading(on_type);
      jump('single_inspection_' + inspection_id);
      //$('button.btn.btn-default.inspection_status[inspection_id=' + inspection_id + ']').text(value);
      //label_file = value.toLowerCase().replace(' ', '_') + ".png";
      //label_file_path = "/assets/labels/" + label_file;
      //$('img.property_image_label[inspection_id=' + inspection_id + ']').attr('src', label_file_path);
    }
  });
}

//close auto-send email colorbox after saving
function click_save_set() {
  console.log('clicked save-set...');
  $('#cboxClose').click();
}

function select_status(){
  console.log('in select#status');
  $('input.inspection_filter_submit').click();
}

function select_all(event){
  console.log('select all..');
  elem = event.target;
  inspection_id = $(elem).attr('inspection_id');
  checked = event.target.checked;
  $("input.select_lead[inspection_id=" + inspection_id + "]").prop('checked', checked);
}

// rating
function set_rating(event){
  console.log('set rating');
  inspection_lead_id = $(event.target).parent().attr('inspection_lead_id');
  console.log("inspection_lead_id: " + inspection_lead_id);
  rating = $(event.target).attr('rating');
  console.log("rating: " + rating);
  $.ajax({
    method: "POST",
    url: "/inspections_leads/set_rating",
    dataType: "script",
    data: { rating: rating, inspection_lead_id: inspection_lead_id }
  })
}

//create inspection button
function create_inspection(event){
  console.log('create_inspection...');
  // Use jQuery.event.fix(event) to normalise event objects for cross browser support as e.preventDefault() is not supported by IE.
  event = $.event.fix(event); 
  event.preventDefault();
  elem = event.target;
  // $(elem).children('i').removeClass('fa-plus').addClass('fa-spinner fa-spin');
  $(elem).children('i').addClass('hide');
  $(elem).children('img').removeClass('hide');
  $(elem).attr('disabled', 'disabled');
  inspection_id = $(elem).attr('inspection_id');
  on_type = $(elem).attr('on_type');
  $.ajax({
    method: "POST",
    url: "/inspections/create_default",
    dataType: "script",
    data: {'type': on_type}
  });
}

function delete_inspection(event) {
  elem = event.target;
  inspection_id = $(elem).attr('inspection_id');
  bootbox.confirm("Are you sure you want to delete this listing? All listing data and property files will be permanently removed.", function(result) {
    if (result === false)
      return;
    $.ajax({
      method: "DELETE",
      url: "/inspections/" + inspection_id,
      dataType: "script"
    })
      .done(function( data ) {
        send_notification('success', "Delete succeeded");
      })
      .fail(function( data ) {
        send_notification('error', "Delete failed");
      });
  });
}

//collapse bar
function collapse_attendees(event){
  console.log('collapsing...');
  $(event.target).parents('.table.inspection_item').find('.details a').click();
}

//show email when icon got hovered
function show_email_text(event){
  $(event.target).hide();
  $(event.target).next().css('display','inline-block').show();
}

function show_email_icon(event){
  $(event.target).hide();
  $(event.target).prev().show();
}

function showAllEmailIcons(element){
  $(element).parents('.inspection_item').find('.email span').hide();
  $(element).parents('.inspection_item').find('.email img').show();
}

function colorSelected(){
  $("input.select_lead:checked").each(function(index, element){
    $(element).parents('tr[class^="lead_inspections_"]').css('background-color','#FFFFCC');
  })
}

//re-pick selectAll checkbox
function isSelectedAll(){
  $('.inspection_leads').each(function(index,element){
    attendeeCount = $(element).find('tr[class^="lead_inspections_"]').length;
    //console.log(attendeeCount);
    if(attendeeCount == $(element).find('input.select_lead:checked').length && attendeeCount != 0 ){
      $(element).find('.select_all').prop('checked',true);
    }
    else 
      $(element).find('.select_all').prop('checked',false)
  })
}

function isRealEmpty(){
  $('.spacer').next().each(function(index,element){
    if($(element).find('.filter_type').val() !== "All" || $(element).find('.lead-body-row tr[class^="lead_inspections_"]').length != 0)
      $(this).addClass('not_empty');
  })
}

//Don't display no data image under empty filters
//WEB-431
function isNodata(){
  $('.not_empty').each(function(index,element){
    list = $(element).find('tr[class^="lead_inspections_"]');
    if($(list).length == 0) {
      $(element).find('.lead_placeholder').hide();
    }
  });
  //list = $(tag).parents('tr[id^="inspection_leads_"]').find('tr[class^="lead_inspections_"]');
}

//no icon for empty 
function isEmailEmpty(){
  $('.email').each(function(index,element){
    if(!$.trim($(element).find('span').text())) {
      $(element).find('img').addClass('hide');
    }
  })
}


