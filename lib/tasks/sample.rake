namespace :sample do
  desc "Generate sample data for new user"
  task sample_data: :environment do
    require 'sample'
    include Sample

    psw = "11111111"
    users = [ 
      ["Kevin","Qian","guorong.qian@hotmail.com","0417273612","101", "kevins ipad", "agenter", "Agent(License)", "free", "1", 
        "88 431 522 096", "431 522 096", "http://kevin.com", "default_profile_picture.png", "bp", "NSW", "2137", "Australia", "The best seller", 
        "reset_password_token_1", "2015-02-22", "2015-02-23", 10, "2015-03-9", "2015-03-9", "192.168.0.1", "192.168.0.10", 
        "2015-02-20", "2015-03-08", true, "default_company_logo.png", "9827 7162", "9817 7263", "237 kevin street"], 
        ["xiangwei","Meng","xwmeng@gmail.com","412736273","100", "xiangwei ipad", "agent-mate", "Principal", "professional", "2", 
          "87 127 273 012", "127 273 012", "http://xiangwei.com", "default_profile_picture.png", "concord", "Vic", "3172", "Australia", 
          "The best agent", "reset_password_token_2", "2015-02-12", "2015-02-13", 20, "2015-03-10", "2015-03-9", "192.168.0.2", 
          "192.168.0.20", "2015-02-22", "2015-03-09", true, "default_company_logo.png", "9827 6200", "9817 7200", "237 bp street"],
        ["Zhendong","Zhao","zhaozhendong@gmail.com","0413727361","102", "zhendongs ipad", "remax", "Principal", "free", "3", 
          "87 117 273 281", "117 273 281", "http://zhendong.com", "default_profile_picture.png", "ker", "NSW", "4272", "Australia", 
          "The best agent", "reset_password_token_3", "2015-02-12", "2015-02-13", 20, "2015-03-10", "2015-03-9", "192.168.0.2", 
          "192.168.0.20", "2015-02-22", "2015-03-09", false, "default_company_logo.png", "9827 0000", "9817 0000", "428 roger street"]
    ]

    users.each do |user| 
      #User.create( :first_name => "Kevin", :last_name => "Qian", :password => '1qaz2wsx', :email =>  "kevin@qian.com", :mobile => "0417273612", :device_id => "101")
      first_name, last_name, email, mobile, device_id, device_name, business_name, title, account_type, account_id, abn, acn, website, 
      profile_picture, suburb, state, postcode, country, introduction, reset_password_token, reset_password_sent_at, 
      remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, 
      created_at, updated_at, enabled, company_logo, telephone, fax, address  = user

      ##puts first_name, last_name, email, mobile, device_id, device_name, business_name, title, account_type, account_id, abn, acn, website, profile_picture, suburb, state, postcode, country, introduction, reset_password_token, reset_password_sent_at, remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, created_at, updated_at, enabled, company_logo, telephone, fax, address
      user = User.new( :first_name => first_name, :last_name => last_name, :password => psw, :email =>  email, :mobile => mobile, 
          :device_id => device_id, :device_name => device_name, :business_name => business_name,  :title => title, 
          :account_type => account_type, :account_id => account_id, :abn => abn, :acn => acn, :website => website, 
          :profile_picture => profile_picture, :suburb => suburb, :state => state, :postcode => postcode, :country => country, 
          :introduction => introduction, :enterprise_account_id => "1",
          :reset_password_sent_at => reset_password_sent_at, :remember_created_at => remember_created_at, 
          :sign_in_count => sign_in_count,  :current_sign_in_at => current_sign_in_at, :current_sign_in_ip => current_sign_in_ip, 
          :created_at => created_at, :updated_at => updated_at, :enabled => enabled, 
          :company_logo => company_logo, :telephone => telephone, :fax => fax, :address => address) #, :last_sign_in_at => last_sign_in_at)

      user.verification_code = user.build_verification_code
      user.save!
      sample_data(user)
    end


  end

end
