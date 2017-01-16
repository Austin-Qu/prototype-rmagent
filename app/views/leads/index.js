// render panel heading
$(".panel-heading.leads").html("<%= escape_javascript(render partial: 'lead_panel_heading', locals: {:on_type => @type}) %>");
// render main panel
$(".panel-body.leads").html("<%= escape_javascript(render partial: 'lead_panel_body', locals: {:leads => @leads, :on_type => @type}) %>");
// init leads javascript code
init_leads();
