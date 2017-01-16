if @error.blank?
  json.result "OK" 
  json.user_id @user.id
  json.profile_picture @user.profile_picture_url
  json.logo_url @user.company_logo_url
  user_type = Rails.application.config.user_account_types.index(@user.account_type.nil? ? "Free" : @user.account_type.titleize)
  json.user_type user_type.nil? ? 0 : user_type
else
  json.result "ERROR" 
  json.error @error
  json.error_code @error_code
  json.device_name  @user.device_name unless @user.blank?
  json.current_sign_in_at  @user.current_sign_in_at.to_time.to_i unless @user.blank? or @user.current_sign_in_at.blank?
  json.last_sign_in_at @user.last_sign_in_at.to_time.to_i unless @user.blank? or @user.last_sign_in_at.blank?
end
