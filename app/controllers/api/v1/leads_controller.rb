module Api
  module V1
    class LeadsController < ApplicationController
      skip_before_filter  :verify_authenticity_token 

      def get_leads_by_inspection
        @error = ""
        user_id = params[:user_id]
        device_id = params[:device_id]
        inspection_id = params[:inspection_id]
        if not User.exists?(user_id)
          @error = "User not found"
        else
          user = User.find(user_id)
          if user.device_id != device_id
            @error = "User with wrong device id"
          else
            if Inspection.exists?(inspection_id)
              @inspection = Inspection.find(inspection_id)
            else
              @error = "Inspection not found"
            end
          end
        end
      end

      def get_all_leads_by_user
        @error = ""
        user_id = params[:user_id]
        device_id = params[:device_id]
        if not User.exists?(user_id)
          @error = "User not found"
        else
          user = User.find(user_id)
          if user.device_id != device_id
            @error = "User with wrong device id"
          else
            @leads = Lead.joins(:leads_users).where('leads_users.user_id = ?', user_id)
          end
        end
      end

      def upload_leads_for_inspection
        logger.debug "in upload_leads_for_inspection..."
        logger.debug params.inspect
        @error = ""
        user_id = params[:user_id]
        device_id = params[:device_id]
        inspection_id = params[:inspection_id]
        leads_data = params[:leads]
        ## verify the device id first
        if not User.exists?(user_id)
          @error = "User not found"
        else
          user = User.find(user_id)
          if user.device_id != device_id
            @error = "User with wrong device id"
          else
            #update inspection time
            user_lead_on_type = "Buyer" 
            if Inspection.exists?(inspection_id)
              logger.debug ">>>> updating the latest inspection time"
              inspection = Inspection.find(inspection_id)
              inspection.last_updated = Time.zone.now
              inspection_on_type = Rails.application.config.on_type_mapping_inspection_leads[inspection.on_type]
              logger.debug ">>>> updating at #{inspection.last_updated}"
              inspection.save
            end
            leads_data.each do |lead_data|
              lead_data[:inspection_id] = inspection_id
              id = lead_data[:id]
              is_lead_exist = Lead.exists?(id)
              if id.blank? || !is_lead_exist # a new register, or the lead has been deleted
                # insert
                telephone = lead_data[:telephone]
                existing_lead = Lead.where(:telephone => telephone).first
                if existing_lead.blank?
                  logger.debug "new lead"
                  lead = Lead.new
                  inspection_lead = InspectionsLead.new
                  inspection_lead_send_file = false
                  lead, inspection_lead = update_lead(lead_data, lead, inspection_lead, user_id, inspection_on_type)
                else
                  logger.debug "existing lead"
                  inspection_lead = InspectionsLead.where(:lead_id => existing_lead.id, :inspection_id => inspection_id).first
                  if inspection_lead.blank?
                    inspection_lead = existing_lead.inspections_leads.build
                    inspection_lead_send_file = false
                  else
                    inspection_lead_send_file = inspection_lead.send_file
                  end
                  update_lead(lead_data, existing_lead, inspection_lead, user_id, inspection_on_type)
                end

              else # an exist user
                logger.debug ">> existing lead with id"
                # update
                lead = Lead.find(lead_data[:id])
                inspection_lead = InspectionsLead.where(:lead_id => lead.id, :inspection_id => inspection_id).first
                logger.debug "debug ...inspection_lead: #{inspection_lead.inspect}"
                if inspection_lead
                  logger.debug ">>>>  inspection_lead exists. "
                  inspection_lead_send_file = inspection_lead.send_file
                  update_lead(lead_data, lead, inspection_lead, user_id, inspection_on_type)
                else ## this lead could be added in the website, create a new inspection_lead relation
                  logger.debug ">>>> ... inspection_lead does not exist."
                  inspection_lead = InspectionsLead.new
                  inspection_lead_send_file = false
                  update_lead(lead_data, lead, inspection_lead, user_id, inspection_on_type)
                end
              end
              logger.debug "start sending files"
              logger.debug lead_data.inspect
              logger.debug lead_data[:send_file] == 1
              # send property files after lead is updated
              ipad_send_file = lead_data[:send_file] == 1
              send_files(ipad_send_file, inspection_lead, user_id, inspection_lead_send_file)
            end # end for each lead
          end # end if @user.device_id != device_id
        end # end if not User.exists?(user_id)
      end


      private

        def lead_params
          params.require(:lead).permit(:first_name, :last_name, :telephone, :email, :icon)
        end


        def update_lead(lead_data, lead, inspection_lead, user_id, inspection_on_type)
          logger.debug "in update_lead..."
          # inspection_lead = nil
          begin
            lead_data.delete("id")
            lead_data_hash = lead_data.select{|k,v| lead.attribute_names.include?(k)}
            logger.debug "lead_data_hash: #{lead_data_hash.inspect}"
            lead.update_attributes(lead_data_hash.permit(:name, :telephone, :email, :last_name, :first_name, :icon))
            logger.debug "lead updated"
            logger.debug "inspection_lead: #{lead.inspect}"
            inspection_lead_data_hash = lead_data.select{|k,v| inspection_lead.attribute_names.include?(k)}
            inspection_lead_data_hash["lead_id"] = lead.id
            logger.debug "inspection_lead_data_hash: #{inspection_lead_data_hash.inspect}"
            # incoming datetime in in unix timestamp
            inspection_lead_data_hash["inspection_datetime"] = Time.at(inspection_lead_data_hash["inspection_datetime"]) unless inspection_lead_data_hash["inspection_datetime"].blank?
            # update count_inspections
            count_inspection_lead = inspection_lead["count_inspections"].nil? ? 0 : inspection_lead["count_inspections"] 
            inspection_lead_data_hash["count_inspections"] = count_inspection_lead + 1
            logger.debug ">>>> inspection times: #{count_inspection_lead}"
            inspection_lead_data_hash["count_follow_ups"] = inspection_lead["count_follow_ups"].nil? ? 0 : inspection_lead["count_follow_ups"] 
            # set followup type WEB-81
            set_followup_type(inspection_lead_data_hash)
            inspection_lead_data_hash["last_follow_up"] = inspection_lead_data_hash["inspection_datetime"]
            # set follow_up_by
            inspection_lead_data_hash["follow_up_source_id"] = user_id
            # set inspected 
            inspection_lead_data_hash["inspected"] = true
            inspection_lead.update_attributes(inspection_lead_data_hash.permit(:lead_id, :inspection_id, :offer_price, :send_file, :rating, :inspection_datetime, :memo, 
                                              :last_follow_up_type, :last_follow_up, :count_inspections, :inspected, :count_follow_ups, :follow_up_source_id))
            logger.debug "inspection_lead updated"
            logger.debug "inspection_lead: #{inspection_lead.inspect}"

            ## update lead user on_type WEB-262
            logger.debug ">>>> updating user lead on_type..."
            logger.debug ">>>> user: #{user_id}, lead: #{lead.id}, on_type: #{inspection_on_type}"
            has_user_lead_relation = LeadsUser.where(:user_id => user_id, :lead_id => lead.id, :on_type => inspection_on_type).first
            logger.debug ">>>> user: #{user_id}, lead: #{lead.id}, on_type: #{inspection_on_type}, ha_relation: #{has_user_lead_relation}"
            if !has_user_lead_relation
              logger.debug ">>>> Does NOT have, create a new relation"
              user_lead = LeadsUser.new({:user_id => user_id, :lead_id => lead.id, :source => user_id, :on_type => inspection_on_type})
              user_lead.save
              logger.debug ">>>> Saved! #{user_lead.inspect}"
            end
          rescue => ex
            logger.error ex.backtrace.join("\n")
            @error = ex.message
          end
          return lead, inspection_lead
        end

        def set_followup_type(inspection_lead_data_hash)
          logger.debug ">> in set followup type"
          has_sent_file = inspection_lead_data_hash["send_file"]>0
          has_rated = inspection_lead_data_hash["rating"]>0
          has_offered = inspection_lead_data_hash["offer_price"]>0
          has_memo = !inspection_lead_data_hash["memo"].blank?
          
          if has_sent_file || has_rated || has_offered || has_memo
            logger.debug "ipad follow-up"
            inspection_lead_data_hash["last_follow_up_type"] = Rails.application.config.followup_types[1] # "ipad follow-up"
            inspection_lead_data_hash["count_follow_ups"] += 1
          else
            logger.debug "Newly Registered"
            inspection_lead_data_hash["last_follow_up_type"] = Rails.application.config.followup_types[0] # "Newly Registered"
          end
        end

        def send_files(ipad_send_file, inspection_lead, user_id, inspection_lead_send_file)
          logger.debug "in send_file..."
          logger.debug "ipad_send_file: #{ipad_send_file}"
          return if inspection_lead.blank?
          inspection = inspection_lead.inspection
          inspection_send_file = inspection_lead.inspection.send_file
          if ipad_send_file
            logger.debug "Send file: iPad Y"
            if inspection_send_file
              logger.debug "Send file: Web Y"
              if inspection_lead_send_file
                logger.debug "Send file: inspection_lead Y"
                # 1. If file has been sent before, do nothing. 
              else
                logger.debug "Send file: inspection_lead N"
                # 2. If file hasn't been sent, send the file and update the followup_status to 'Email sent', set inspection_lead send_file to Y 
                # send file
                send_mail(inspection_lead, user_id)
                inspection_lead.last_follow_up_type = "Email Sent"
                inspection_lead.send_file = true
                inspection_lead.save
              end
            else
              logger.debug "Send file: Web N"
              # update followup_status to 'Email requested', set inspection_lead send_file to N 
              inspection_lead.last_follow_up_type = "Email Requested"
              if inspection_lead.send_file
                inspection_lead.send_file = false
                inspection_lead.save
              end
            end
          else
            logger.debug "Send file: iPad N"
            # update followup_status to 'Email requested' 
            if inspection_lead.send_file
              inspection_lead.send_file = false
              inspection_lead.save
            end
          end

        end

        def send_mail(inspection_lead, user_id)
          logger.debug ">> in send_mail..."
          logger.debug ">> inspection_lead: #{inspection_lead.inspect}, user_id: #{user_id}"
          template_type = 'File Send'
          inspection = inspection_lead.inspection
          lead = inspection_lead.lead
          user = User.find(user_id)
          email_template = EmailTemplate.where(:template_type => template_type, :inspection_id => inspection.id).first
          recipient = lead.email 
          property_files = Array.new
          #full_address = "#{inspection.street_address}, #{inspection.suburb}, #{inspection.state}, #{inspection.postcode}".titleize
          unless email_template.blank? # using template
            email_subject = email_template.subject
            email_body = email_template.body
            property_files = email_template.property_files.split(',') unless email_template.property_files.blank?
          else
            email_subject = Rails.application.config.email_setting_fs_subject
            email_body = Rails.application.config.email_setting_fs_body
            property_files = inspection.property_files.split(',') unless inspection.property_files.blank?
          end
          logger.debug "subject: #{email_subject}, full_address: #{inspection.get_full_address}"

          unless email_subject.blank?
            subject = email_subject.gsub('[ADDRESS]', inspection.get_full_address)
          else
            subject = "Files you requested"
          end
          body = email_body.gsub('[ATTENDEE]', lead.first_name)
              .gsub('[ADDRESS]', inspection.get_full_address)
              .gsub('[AGENCY LOGO]', "<img src=\"#{user.company_logo_url}\"  width=\"220px\" height=\"41px\" >")
              .gsub('[AGENT NAME]', user.full_name)
              .gsub('[AGENT EMAIL]', user.email)
              .gsub('[AGENT MOBILE]', user.mobile)
              .gsub('[AGENT COMPANY]', user.business_name)
          if inspection.listing_url.blank?
            body = body.gsub(/\s*[Ss]ee\s+\[LISTING_WEBSITE\]\s*\./, "") # remove it
          else
            body = body.gsub('[LISTING_WEBSITE]', inspection.listing_url)
          end
          logger.debug ">>>> Body: #{body}"
          attached_files = Hash.new
          logger.debug "debug2"
          property_files.each do |property_file|
            next if property_file.blank?
            attached_files[property_file] = inspection.property_file_url(property_file)
          end
          logger.debug "debug3"
          from = user.email #Rails.application.config.info_email
          #recipients.split(',').each do |recipient|
          logger.debug ">>>> from #{from}, to #{recipient}, subject: #{subject}"
          UserMailer.bulk_email(from, subject, recipient, body, attached_files).deliver_now
          #end
          logger.debug "debug4"
        end

        # def query_params
        #   # this assumes that an album belongs to an artist and has an :artist_id
        #   # allowing us to filter by this
        #   params.permit(:id, :street_address)
        # end

    end
  end
end