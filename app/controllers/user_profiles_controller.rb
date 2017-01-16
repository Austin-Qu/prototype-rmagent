class UserProfilesController < ApplicationController
  include ApplicationHelper

  require 'fileutils'
  # GET /user_profiles/1
  # GET /user_profiles/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  def ajax_update
    attr_name = params["name"]
    # attr_name.slice!("_#{params["pk"]}")
    attr_value = params["value"]
    user = User.find(params["pk"])
    json_data = Hash.new
    if attr_name == "suburb_state_postcode"
      if not attr_value.blank? and attr_value.split(',').count == 3
        user.suburb = attr_value.split(',')[0].strip
        user.state = attr_value.split(',')[1].strip
        user.postcode = attr_value.split(',')[2].strip
        saved = user.save
      else
        json_data[params["name"]] = user.suburb_state_postcode
        json_data['updated?'] = false
      end
      # user.suburb = attr_value.split(',')[0].strip
      # user.state = attr_value.split(',')[1].strip
      # user.postcode = attr_value.split(',')[2].strip
    else
      user.attributes = {attr_name => attr_value}
      saved = user.save 
    end
    json_data.merge!(user.attributes)
    respond_to do |format|
      format.json { 
        if saved.nil? 
          render :json => json_data.to_json 
        elsif saved
          render :status => 227, :json => user
        else
          json_data = {:status => 'error', :msg => user.errors.full_messages.first}
          render :status => 200, :json => json_data
        end

        # if user.save
        #   render :json => user.to_json 
        # else
        #   json_data = {:status => 'error', :msg => user.errors.full_messages.first}
        #   logger.debug "json_data: #{json_data.inspect}"
        #   render :status => 200, :json => json_data
        # end
      }
    end
  end

  def upload
    logger.debug "uploading ..."
    name = params[:attribute_name]
    current_user = User.find(params[:user_id])
    logger.debug "current_user: #{current_user.inspect}"
    if name == "company_logo"
      file_path = current_user.company_logo_path
    else
      file_path = current_user.profile_picture_path
    end
    profile_image_dir_abs_path = Rails.root.join('public', current_user.profile_image_dir)
    logger.debug "profile_image_dir_abs_path: #{profile_image_dir_abs_path}"
    FileUtils.mkdir_p(profile_image_dir_abs_path) unless File.directory?(profile_image_dir_abs_path)
    uploaded_io = params[:file]
    file_abs_path = Rails.root.join('public', file_path)
    File.delete(file_abs_path) if File.exist?(file_abs_path)
    filename = uploaded_io.original_filename
    filename = sanitize_filename(filename)
    file_abs_path = Rails.root.join(profile_image_dir_abs_path, filename)
    File.open(file_abs_path, 'wb') do |file|
      file.write(uploaded_io.read)
    end
    current_user.update_attribute(name, filename)
    current_user.save
    redirect_to :back
  end

  def get_user_profile
    attribute_name = params[:attribute_name]
    current_user = User.find(params[:user_id])
    if attribute_name == 'profile_picture'
      url = current_user.profile_picture_url
    else
      url = current_user.company_logo_url
    end
    respond_to do |format|
      format.json { 
        json_data = {:url => url}
        logger.debug "json_data: #{json_data.inspect}"
        render :status => 200, :json => json_data
      }
    end




  end

end
