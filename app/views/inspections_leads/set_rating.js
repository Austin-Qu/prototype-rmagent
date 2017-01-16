ratings = $(".rating[inspection_lead_id=<%= @inspection_lead_id %>] i");
new_rating_num = parseInt("<%= @rating %>");
ratings.each( function() {
  rating = $(this);
  rating_num = parseInt(rating.attr('rating'));
  if (rating_num <= new_rating_num) {
    rating.addClass('rating_on');
  }
  else {
    rating.removeClass('rating_on');
  }
});

// update inspection count panel
$(".inspection_item_line4[inspection_id=<%=@inspection_lead.inspection.id%>]").html("<%= escape_javascript(render partial: '/inspections/inspection_lead_count_panel', locals: {:inspection => @inspection_lead.inspection}) %>");
