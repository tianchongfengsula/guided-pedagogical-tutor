# config/importmap.rb
pin "application", to: "application.js", preload: true # <- NOTE: This to: "application.js", preload: truemight be a dirty fix to the firefox's strict implementations about modules ughhh
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# This is the critical line that maps "controllers/xxx"
pin_all_from "app/javascript/controllers", under: "controllers"
