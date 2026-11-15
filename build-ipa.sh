#!/usr/bin/env bash
# build-ipa.sh — Build IPA CHƯA KÝ (unsigned) cho Respring 27.
# Chạy trên Mac có Xcode 16+ và XcodeGen (brew install xcodegen).
# Kết quả: build/Respring27-unsigned.ipa — mang file này vào Feather để
# ký bằng chứng chỉ Developer của bạn rồi cài lên iPhone.
#
# KHÔNG chạy được trên Linux (không có Xcode/Swift toolchain) — xem README.md.
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "Lỗi: chưa có xcodegen. Cài bằng: brew install xcodegen" >&2
  exit 1
fi
if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "Lỗi: chưa có xcodebuild. Cần Mac có Xcode 16+." >&2
  exit 1
fi

echo "==> Sinh .xcodeproj từ project.yml ..."
xcodegen generate

echo "==> Archive (không ký) ..."
rm -rf build
xcodebuild archive \
  -project Respring27.xcodeproj \
  -scheme Respring27 \
  -destination "generic/platform=iOS" \
  -archivePath build/Respring27.xcarchive \
  -configuration Release \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO

APP_PATH="build/Respring27.xcarchive/Products/Applications/Respring27.app"
if [ ! -d "$APP_PATH" ]; then
  echo "Lỗi: không tìm thấy $APP_PATH sau khi archive." >&2
  exit 1
fi

echo "==> Đóng gói IPA chưa ký ..."
rm -rf build/Payload build/Respring27-unsigned.ipa
mkdir -p build/Payload
cp -R "$APP_PATH" build/Payload/
( cd build && zip -qr Respring27-unsigned.ipa Payload )
rm -rf build/Payload

echo "==> Xong: build/Respring27-unsigned.ipa"
ls -lh build/Respring27-unsigned.ipa
unzip -l build/Respring27-unsigned.ipa | head -20
