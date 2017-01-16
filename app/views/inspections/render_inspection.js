console.log('entering render_inspection.js');
selected_inspection_lead_ids_string = "<%= @selected_inspection_lead_ids.blank? ? '' : @selected_inspection_lead_ids.join(',') %>";
console.log('selected_inspection_lead_ids: ' + selected_inspection_lead_ids);
$("tr.single_inspection[inspection_id=<%= @inspection.id %>]").html("<%= escape_javascript(render partial: 'single_inspection', locals: {:ins => @inspection, :on_type => @on_type}) %>");
if (selected_inspection_lead_ids_string !== ''){
  console.log('debug1');
  selected_inspection_lead_ids = selected_inspection_lead_ids_string.split(',');
  $.each(selected_inspection_lead_ids, function(idx, inspection_lead_id){
    console.log('looping inspection_lead_id ' + inspection_lead_id);
    $('input.select_lead[inspection_lead_id=' + inspection_lead_id + ']').prop('checked', true);
  });
  console.log('debug2');
  $("a.inspection_leads_details[inspection_id=<%= @inspection.id %>]").click();
  console.log('debug3');
  jump("inspection_leads_<%= @inspection.id %>");
}
console.log('in render_inspections before init_for_sale');
init_for_sale();
console.log('in render_inspections after init_for_sale');

