// Upload property files
function init_plupload(inspection_id) {
  console.log('in init_plupload ... inspection_id: ' + inspection_id);
  // Setup html5 version
  var uploader = $("#uploader_files").pluploadQueue({
    // General settings
    runtimes : 'html5,flash,silverlight,html4',
    url : "/inspections/upload_property_file.json?inspection_id=" + inspection_id,
    //chunk_size: '1mb',
    rename : true,
    dragdrop: true,
    
    filters : {
      // Maximum file size
      max_file_size : '25mb'
      // Specify what files to browse for
      //mime_types: [
      //  {title : "Image files", extensions : "jpg,jpeg,gif,png"},
      //  {title : "Zip files", extensions : "zip"},
      //  {title : "PDF document", extensions : "pdf"}
      //]
    },

    init: {
      Init: function(up) {
        console.log('init...');
        $('#upload_files_colorbox .plupload_header_botline').text("Add/drag files from your computer. To begin upload, click ‘Start Upload’.");
        $('#upload_files_colorbox .plupload_header_subtitle').text('(Single file size limit - 25MB )');
        $('.plupload_container').removeAttr("title");
        up.refresh();
      },
      Error: function(up, err) {
        file = err.file.name;
        if (err.status === 520)
          send_notification("error", file + " has been uploaded. Please rename and upload again.");
      },
      UploadComplete: function(up, err) {
        if (err[0].percent === 100) {
          $('#upload_files_colorbox').colorbox.close();
          send_notification("success", "Upload successful.");
        }
        else
          send_notification("error", "Upload failed.");
      }
    },



    // Resize images on clientside if we can
    //resize : {width : 320, height : 240, quality : 90},

    flash_swf_url : '../../js/Moxie.swf',
    silverlight_xap_url : '../../js/Moxie.xap'
  });

  console.log('before init');
  uploader.init();
  console.log('after init');

}

// Upload inspection image
function init_plupload_image(inspection_id) {
  console.log('in init_plupload_image... inspection_id: ' + inspection_id);  
  // Setup html5 version
  var uploader = $("#uploader_image").pluploadQueue({
    // General settings
    runtimes : 'html5,flash,silverlight,html4',
    url : "/inspections/upload?inspection_id=" + inspection_id,
    //chunk_size: '1mb',
    rename : true,
    dragdrop: true,
    multi_selection: false,
    // Views to activate
    views: {
        list: true,
        thumbs: true, // Show thumbs
        active: 'thumbs'
    },
    // Resize images on clientside if we can
    resize : {
        width : 800,
        height : 600,
        quality : 90,
        crop: false // crop to exact dimensions
    },
    
    filters : {
      // Maximum file size
      max_file_size : '25mb',
      // Specify what files to browse for
      mime_types: [
        {title : "Image files", extensions : "jpg,jpeg,gif,png,bmp"}
      ]
    },

    init: {
      Init: function(up) {
        $('#upload_image_colorbox .plupload_header_title').text('Upload Property Image');
        $('#upload_image_colorbox .plupload_header_subtitle').text('(Recommended Size: 1024px x 768px)');
        $('#upload_image_colorbox .plupload_header_botline').text('Add/drag images from desktop, file will be uploaded and resized automatically.');
        $('#upload_image_colorbox .plupload_header_content').css('background-url','/assets/plupload/backgrounds_image.gif');
        $('#upload_image_colorbox .plupload_header_content').css('background-image',"url('/assets/plupload/backgrounds_image.gif')");
        setTimeout(function(){$('#upload_image_colorbox .plupload_droptext').html('Drag image here.');}, 100);
        $('#upload_image_colorbox .plupload_start').hide();        
        $('.plupload_container').removeAttr("title");
      },
      Error: function(up, err) {
        file = err.file.name;
        if (err.status === 520)
          send_notification("error", file + " has been uploaded. Please rename and upload again.");
      },
      QueueChanged: function(up) {
        if ( up.files.length > 0 && uploader.state != 2) {
          up.start();
        }
        //if ( up.files.length > 1 )
        //  up.splice(1,1);
      },
      UploadComplete: function(up, err) {
        if (err[0].percent === 100)
          $('#upload_image_colorbox').colorbox.close();
        else
          send_notification("error", "Upload failed.");
      }
    },

    // Resize images on clientside if we can
    //resize : {width : 320, height : 240, quality : 90},

    flash_swf_url : '../../js/Moxie.swf',
    silverlight_xap_url : '../../js/Moxie.xap'
  });

  uploader.init();


}

// Upload user profile picture
function init_plupload_user_profile(attribute_name, user_id) {
  console.log("attribute_name: " + attribute_name + " user_id: " + user_id);
  // attribute_name: profile_picture/company_logo
  // Setup html5 version
  var uploader = $("#uploader_user_profile").pluploadQueue({
    // General settings
    runtimes : 'html5,flash,silverlight,html4',
    url : "/user_profiles/upload?attribute_name=" + attribute_name + "&user_id=" + user_id,
    //chunk_size: '1mb',
    rename : true,
    dragdrop: true,
    multi_selection: false,
    // Views to activate
    views: {
        list: true,
        thumbs: true, // Show thumbs
        active: 'thumbs'
    },
    // Resize images on clientside if we can
    resize : {
        width : 160,
        height : 160,
        quality : 90,
        crop: false // crop to exact dimensions
    },
    
    filters : {
      // Maximum file size
      max_file_size : '25mb',
      // Specify what files to browse for
      mime_types: [
        {title : "Image files", extensions : "jpg,jpeg,gif,png,bmp"}
      ]
    },

    init: {
      Init: function(up) {
        $('#upload_user_profile_image_colorbox .plupload_header_title').text('Upload Photo');
        $('#upload_user_profile_image_colorbox .plupload_header_subtitle').text('(Recommended Size: 480px x 480px)');
        $('#upload_user_profile_image_colorbox .plupload_header_botline').text('Add/drag images from desktop, file will be uploaded and resized automatically.');
        $('#upload_user_profile_image_colorbox .plupload_header_content').css('background-url','/assets/plupload/backgrounds_image.gif');
        $('#upload_user_profile_image_colorbox .plupload_header_content').css('background-image',"url('/assets/plupload/backgrounds_image.gif')");
        setTimeout(function(){$('#upload_user_profile_image_colorbox .plupload_droptext').html('Drag image here.');}, 100);
        $('#upload_user_profile_image_colorbox .plupload_start').hide();
        $('.plupload_container').removeAttr("title");
      },
      Error: function(up, err) {
        file = err.file.name;
        if (err.status === 520)
          send_notification("error", file + " has been uploaded. Please rename and upload again.");
      },
      QueueChanged: function(up) {
        if ( up.files.length > 0 && uploader.state != 2) {
          up.start();
        }
        //if ( up.files.length > 1 )
        //  up.splice(1,1);
      },
      UploadComplete: function(up, err) {
        if (err[0].percent === 100)
          $('#upload_image_colorbox').colorbox.close();
        else
          send_notification("error", "Upload failed");
      }
    },

    // Resize images on clientside if we can
    //resize : {width : 320, height : 240, quality : 90},

    flash_swf_url : '../../js/Moxie.swf',
    silverlight_xap_url : '../../js/Moxie.xap'
  });

  uploader.init();


}

// Upload company logo
function init_plupload_company_logo(attribute_name, user_id) {
  console.log("attribute_name: " + attribute_name + " user_id: " + user_id);
  // attribute_name: profile_picture/company_logo
  // Setup html5 version
  var uploader = $("#uploader_company_logo").pluploadQueue({
    // General settings
    runtimes : 'html5,flash,silverlight,html4',
    url : "/user_profiles/upload?attribute_name=" + attribute_name + "&user_id=" + user_id,
    //chunk_size: '1mb',
    rename : true,
    dragdrop: true,
    multi_selection: false,
    // Views to activate
    views: {
        list: true,
        thumbs: true, // Show thumbs
        active: 'thumbs'
    },
    // Resize images on clientside if we can
    resize : {
        width : 440,
        height : 82,
        quality : 90,
        crop: false // crop to exact dimensions
    },
    
    filters : {
      // Maximum file size
      max_file_size : '25mb',
      // Specify what files to browse for
      mime_types: [
        {title : "Image files", extensions : "jpg,jpeg,gif,png,bmp"}
      ]
    },

    init: {
      Init: function(up) {
        $('#upload_company_logo_colorbox .plupload_header_title').text('Upload Company Logo');
        $('#upload_company_logo_colorbox .plupload_header_subtitle').text('(Recommended Size: 880px x 164px)');
        $('#upload_company_logo_colorbox .plupload_header_botline').text('Add/drag images from desktop, file will be uploaded and resized automatically.');
        $('#upload_company_logo_colorbox .plupload_header_content').css('background-image',"url('/assets/plupload/backgrounds_image.gif')");
        setTimeout(function(){$('#upload_company_logo_colorbox .plupload_droptext').html('Drag image here.');}, 100);
        $('#upload_company_logo_colorbox .plupload_start').hide();
        $('.plupload_container').removeAttr("title");
      },
      Error: function(up, err) {
        file = err.file.name;
        if (err.status === 520)
          send_notification("error", file + " has been uploaded. Please rename and upload again.");
      },
      QueueChanged: function(up) {
        if ( up.files.length > 0 && uploader.state != 2) {
          up.start();
        }
        //if ( up.files.length > 1 )
        //  up.splice(1,1);
      },
      UploadComplete: function(up, err) {
        if (err[0].percent === 100)
          $('#upload_image_colorbox').colorbox.close();
        else
          send_notification("error", "Upload failed");
      }
    },

    // Resize images on clientside if we can
    //resize : {width : 320, height : 240, quality : 90},

    flash_swf_url : '../../js/Moxie.swf',
    silverlight_xap_url : '../../js/Moxie.xap'
  });

  uploader.init();


}

// Upload property files
function init_plupload_leads() {
  console.log('initing init_plupload_leads..');
  // Setup html5 version
  var uploader = $("#uploader_leads_files").pluploadQueue({
    // General settings
    runtimes : 'html5,flash,silverlight,html4',
    url : "/leads/upload_file.json",
    //chunk_size: '1mb',
    rename : true,
    dragdrop: true,
    
    filters : {
      // Maximum file size
      max_file_size : '25mb'
      // Specify what files to browse for
      //mime_types: [
      //  {title : "Image files", extensions : "jpg,jpeg,gif,png"},
      //  {title : "Zip files", extensions : "zip"},
      //  {title : "PDF document", extensions : "pdf"}
      //]
    },

    init: {
      Init: function(up) {
        console.log('init...');
        $('#upload_files_colorbox .plupload_header_botline').text("Add/drag files from your computer. To begin upload, click ‘Start Upload’.");
        $('#upload_files_colorbox .plupload_header_subtitle').text('(Single file size limit - 25MB )');
        $('.plupload_container').removeAttr("title");
        up.refresh();
      },
      Error: function(up, err) {
        file = err.file.name;
        if (err.status === 520)
          send_notification("error", file + " has been uploaded. Please rename and upload again.");
      },
      UploadComplete: function(up, err) {
        if (err[0].percent === 100) {
          $('#upload_files_colorbox').colorbox.close();
          send_notification("success", "Upload successful.");
        }
        else
          send_notification("error", "Upload failed.");
      }
    },



    // Resize images on clientside if we can
    //resize : {width : 320, height : 240, quality : 90},

    flash_swf_url : '../../js/Moxie.swf',
    silverlight_xap_url : '../../js/Moxie.xap'
  });

  console.log('before init');
  uploader.init();
  console.log('after init');

}
