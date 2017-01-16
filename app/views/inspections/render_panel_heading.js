$(".panel-heading.inspections").html("<%= escape_javascript(render partial: 'inspection_panel_heading', locals: {:on_type => @on_type}) %>");
