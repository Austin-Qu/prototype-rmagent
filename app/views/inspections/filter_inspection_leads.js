$("table.inspection_leads[inspection_id=<%= @inspection.id %>]").html("<%= escape_javascript(render partial: 'inspection_leads_rows', locals: {:inspection => @inspection, :inspections_leads => @inspections_leads, :on_type => @on_type}) %>");
//status_icon_change();
init_for_sale();
