module DeviseHelper
  def devise_error_messages!
    logger.debug "dfdf.."
    return "" if resource.errors.empty?

    # Display uniq error messages only
    messages = resource.errors.full_messages.uniq.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)
    # Display empty sentence
    sentence = ""

    html = <<-HTML
    <div id="error_explanation">
      <h2>#{sentence}</h2>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def devise_error_messages?
    resource.errors.empty? ? false : true
  end

end