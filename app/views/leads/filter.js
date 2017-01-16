// render main panel
$(".col-md-12.all_leads_rows").html("<%= escape_javascript(render partial: 'all_leads_rows', locals: {:leads => @leads, :on_type => @type}) %>");