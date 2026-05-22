# Web Push notification initializer
# VAPID keys are stored in Rails credentials
#
# How to generate keys:
#   require 'web-push'
#   vapid_key = WebPush.generate_key
#   puts vapid_key.public_key
#   puts vapid_key.private_key
#
# Add the following to credentials.yml.enc:
#   webpush:
#     public_key: "..."
#     private_key: "..."
#     subject: "mailto:your@email.com"
