function init_leads() {
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
      if ($.cookie('attachments') === undefined) {
        //clean up bulk email attachments
        select_tag = $('select.bulk_email_files');
        select_tag.html("");
        select_tag.multiselect('rebuild');
      }
      // validate added email
      $('input#recipients').on('itemAdded', function(event) {
        email = event.item;
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

      } else {
        $.removeCookie("attachments");
      }
      // deregister email validation
      $('input#recipients').unbind('itemAdded');
    },
    onComplete: function(event){
      console.log('cbox_complete');
      // prefill recipients
      checked = $('input.select_lead:checked');
      $('#colorbox input#recipients').tagsinput('removeAll');
      if ($.cookie('emails') !== undefined) {
        $.each($.cookie('emails').split(','), function(idx, email){
          $('#colorbox input#recipients').tagsinput('add', email);
        });
        $.removeCookie('emails');
      } else {
        $.each(checked, function(i, checked_lead){
          email = $(checked_lead).attr('email');
          console.log(email);
          $('#colorbox input#recipients').tagsinput('add', email);
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
      if ($('#runtime').attr('bulk_email_temp_close') === "1") {
        // closed temporarily as it's closed by upload file
        setTimeout(function(){
          $("a.bulk_email.inline").colorbox.close();
          $("a.bulk_email.inline").click();
          $('#runtime').attr('bulk_email_temp_close', 0);
          // for bulk email attachments
          select_tag = $('select.bulk_email_files');
          attachments = [];
          if ($.cookie('attachments') !== undefined)
            attachments = $.cookie('attachments').split(',');
          $.each(attachments, function(idx, attachment_path){
            attachment_name = _.last(attachment_path.split('/'));
            select_tag.append("<option value='" + attachment_path + "' selected>" + attachment_name + "</option>");
          });
          select_tag.multiselect('rebuild');
        }, 500);
      }
    },
    onOpen: function(event) {
      init_plupload_leads();
    }
  });

  // multiselect property files in bulk email form
  $('select.bulk_email_files').multiselect({
    maxHeight: 200,
    numberDisplayed: 1
  });

  //hover effect for email icon
  emailHover();
 
}

function bulk_email_upload_files(event){
  console.log('clicked a.bulk_email_upload_files..');
  // Use jQuery.event.fix(event) to normalise event objects for cross browser support as e.preventDefault() is not supported by IE.
  event = $.event.fix(event); 
  console.log('debug1');
  event.preventDefault();
  console.log('debug2');
  bulk_email_open = $('#runtime').attr('bulk_email_open');
  bulk_email_colorbox = $("a.bulk_email.inline");
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


//show email when icon got hovered
function show_email_text(event){
  $(event.target).hide();
  $(event.target).next().css('display','inline-block').show();
}

function show_email_icon(event){
  $(event.target).hide();
  $(event.target).prev().show();
}

//re-pick selectAll checkbox(lead page)
function isSelectedAll(){
  if($('#all_leads>tbody').children('tr[class^="lead_inspections_"]').length == $('#all_leads').find('input.select_lead:checked').length){
    $('#all_leads').find('.select_all').prop('checked',true);
  }
  else 
    $('#all_leads').find('.select_all').prop('checked',false);
}

