# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "highlight.js/lib/core", to: "highlight.js--lib--core.js" # @11.9.0
pin "highlight.js/lib/languages/json", to: "highlight.js--lib--languages--json.js" # @11.9.0
pin "highlight.js/lib/languages/dns", to: "highlight.js--lib--languages--dns.js" # @11.9.0
