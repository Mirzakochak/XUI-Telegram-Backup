#!/bin/bash

while true; do
  clear
  echo "========== XUI Telegram Backup =========="
  echo "1) Install"
  echo "2) Uninstall"
  echo "3) Exit"
  read -p "Enter your choice [1-3]: " choice

  case "$choice" in
    1)
      echo "🚀 شروع نصب..."

      # گرفتن اطلاعات
      read -p "🔐 توکن ربات تلگرام: " BOT_TOKEN
      read -p "💬 Chat ID عددی شما: " CHAT_ID
      read -p "⏱️ هر چند ساعت یک‌بار بکاپ ارسال شود؟ (مثلاً 6): " HOURS

      # ساخت اسکریپت بکاپ
      cat <<EOF > /root/xui-backup-telegram.sh
#!/bin/bash
BOT_TOKEN="$BOT_TOKEN"
CHAT_ID="$CHAT_ID"
DATE=\$(date +%F-%H-%M)
DB_FILE="/etc/x-ui/x-ui.db"
BACKUP_NAME="x-ui-backup-\$DATE.db"
TMP_DIR="/root/xui_tmp"
mkdir -p \$TMP_DIR
cp \$DB_FILE \$TMP_DIR/\$BACKUP_NAME
curl -s -X POST "https://api.telegram.org/bot\$BOT_TOKEN/sendDocument" \\
  -F document=@"\$TMP_DIR/\$BACKUP_NAME" \\
  -F chat_id="\$CHAT_ID" \\
  -F caption="🧩 بکاپ XUI - تاریخ \$DATE"
rm -rf \$TMP_DIR
EOF

      chmod +x /root/xui-backup-telegram.sh

      # حذف کرون قبلی (اگه هست)
      crontab -l | grep -v 'xui-backup-telegram.sh' > /tmp/mycron || true
      echo "0 */$HOURS * * * /root/xui-backup-telegram.sh" >> /tmp/mycron
      crontab /tmp/mycron
      rm /tmp/mycron

      echo "✅ نصب با موفقیت انجام شد!"
      read -p "⏎ Enter بزن برای برگشت به منو..." dummy
      ;;

    2)
      echo "🧹 حذف کامل اسکریپت و کرون‌جاب..."
      rm -f /root/xui-backup-telegram.sh
      crontab -l | grep -v 'xui-backup-telegram.sh' > /tmp/mycron || true
      crontab /tmp/mycron
      rm -f /tmp/mycron
      echo "✅ حذف کامل شد."
      read -p "⏎ Enter بزن برای برگشت به منو..." dummy
      ;;

    3)
      echo "👋 خداحافظ!"
      exit 0
      ;;

    *)
      echo "❌ انتخاب نامعتبر"
      read -p "⏎ Enter بزن برای برگشت به منو..." dummy
      ;;
  esac
done
