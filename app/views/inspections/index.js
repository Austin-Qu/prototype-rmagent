on_type = "<%= @type %>";
// render panel heading
$(".panel-heading.inspections").html("<%= escape_javascript(render partial: 'inspection_panel_heading', locals: {:on_type => @type}) %>");
// render main panel
$(".panel-body.inspections").html("<%= escape_javascript(render partial: 'inspection_panel_body', locals: {:inspections => @inspections, :on_type => @type}) %>");
init_for_sale();
