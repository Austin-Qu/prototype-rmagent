// render main panel
$(".row.tab-body-container.inspections").html("<%= escape_javascript(render partial: 'inspection_tab_body', locals: {:inspections => @inspections, :on_type => @type}) %>");
init_for_sale();
