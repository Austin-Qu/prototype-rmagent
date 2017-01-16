// update followup activity in inspections leads page
last_follow_up_type = "<%= @ins_lead.last_follow_up_type%>";
inspection_lead_id = "<%= @ins_lead.id %>";
inspection_id = "<%= @ins_lead.inspection.id %>";
$("div.followup_type[inspection_lead_id=" + inspection_lead_id + "]").text(last_follow_up_type);
// Update status label and status selected value on single inspection
if (last_follow_up_type === "Sold" || last_follow_up_type === "Leased") {
  $('button.inspection_status[inspection_id=' + inspection_id + ']').text(last_follow_up_type);
  $('img.property_image_label[inspection_id=' + inspection_id + ']').attr('src', '/assets/labels/' + last_follow_up_type.toLowerCase() + '.png');
}
// Update last followup time
$("div.followup_time[inspection_lead_id=" + inspection_lead_id + "]").text("<%= time_ago_in_words(@ins_lead.last_follow_up) %> ago");

// update inspection count panel
$(".inspection_item_line4[inspection_id=<%=@ins_lead.inspection.id%>]").html("<%= escape_javascript(render partial: '/inspections/inspection_lead_count_panel', locals: {:inspection => @ins_lead.inspection}) %>");
