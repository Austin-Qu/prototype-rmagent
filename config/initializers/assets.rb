# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path
# Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( jquery-2.1.1.min.js bootstrap.css bootstrap.js bootstrap-editable.min.js bootstrap-editable.css jquery-ui.js jquery-ui.css main.css main.js sidebar.css today.css inspections.css
  leads.css login.css bootstrap-datepicker.js datepicker.css user_profile.css nifty.min.js nifty.min.css pace.min.css pace.min.js fastclick.min.js header.css validator.js
  jquery.colorbox.js colorbox.css bootstrap-multiselect.css bootstrap-multiselect.js underscore-min.js apply_now.css email_sent.css sign_up.css password.css email_sent_pwd.css 404.css typeahead.js-bootstrap.css typeahead.js typeaheadjs.js bloodhound.js bootstrap-switch.min.js bootstrap-switch.min.css
)

Rails.application.config.assets.precompile += %w( bootstrap-tagsinput.css bootstrap-tagsinput.js bootstrap3-typeahead.js fileinput.css fileinput.js )

# landing page
Rails.application.config.assets.precompile += %w( landing/animate.css landing/icon.css landing/font.css landing/app.css landing/landing.css landing/app.js 
    landing/slimscroll/jquery.slimscroll.min.js landing/appear/jquery.appear.js landing/landing.js landing/app.plugin.js landing/jquery.mb.YTPlayer.js
)

# multifile upload
Rails.application.config.assets.precompile += %w( multifile/jquery.MetaData.js multifile/jQuery.MultiFile.min.js multifile/jquery.form.js  )

# plupload
Rails.application.config.assets.precompile += %w( plupload/plupload.full.min.js plupload/jquery.plupload.queue.js plupload/jquery.plupload.queue.css upload_file.js )

# jquery cookie
Rails.application.config.assets.precompile += %w( jquery.cookie.js )

# each page's js
Rails.application.config.assets.precompile += %w( for_sale.js leads.js )

# http://bootboxjs.com/
Rails.application.config.assets.precompile += %w( bootbox.min.js )

# Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/


