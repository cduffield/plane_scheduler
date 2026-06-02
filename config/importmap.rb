# Pin npm packages by running ./bin/importmap

pin "application"
pin_all_from "app/javascript/channels", under: "channels"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/src", under: "src"

# From gems
pin "@hotwired/stimulus", to: "stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin "@rails/activestorage", to: "activestorage.esm.js"
pin "lexxy", to: "lexxy.js"

# Vendor libraries
pin "@hotwired/hotwire-native-bridge", to: "@hotwired--hotwire-native-bridge.js" # @1.2.2
pin "clipboard" # @2.0.11
pin "local-time", to: "local-time.es2017-esm.js"
pin "tailwindcss-stimulus-components" # @6.1.3
pin "@floating-ui/dom", to: "@floating-ui--dom.js" # @1.7.4
pin "@floating-ui/core", to: "@floating-ui--core.js" # @1.7.3
pin "@floating-ui/utils", to: "@floating-ui--utils.js" # @0.2.10
pin "@floating-ui/utils/dom", to: "@floating-ui--utils--dom.js"
pin "@fullcalendar/core", to: "https://esm.sh/@fullcalendar/core@6.1.20"
pin "@fullcalendar/daygrid", to: "https://esm.sh/@fullcalendar/daygrid@6.1.20"
pin "@fullcalendar/interaction", to: "https://esm.sh/@fullcalendar/interaction@6.1.20"
pin "@fullcalendar/list", to: "https://esm.sh/@fullcalendar/list@6.1.20"
pin "@fullcalendar/timegrid", to: "https://esm.sh/@fullcalendar/timegrid@6.1.20"
pin "flatpickr" # @4.6.13
