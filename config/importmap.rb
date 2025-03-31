# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# pin "jquery", to: "jquery2.min.js", preload: true
pin "jquery_ujs", to: "jquery_ujs.js", preload: true
pin "popper", to: "popper.js", preload: true
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "select2.min"
pin "home_page"
pin "jquery.datetimepicker.full"
pin "registration"
pin "match"
pin "teams"
pin "custom"
# pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
