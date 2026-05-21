# Web Push通知の初期設定
# VAPID鍵はcredentialsまたは環境変数で管理する
#
# 鍵の生成方法:
#   require 'web-push'
#   vapid_key = WebPush.generate_key
#   puts vapid_key.public_key
#   puts vapid_key.private_key
#
# credentials.yml.enc に以下を追加:
#   webpush:
#     public_key: "..."
#     private_key: "..."
#     subject: "mailto:your@email.com"
