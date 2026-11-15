# Respring 27 — App respring cho iOS 27.2.1

App iOS tối giản: **mở app là tự respring luôn, không có giao diện** —
không nút, không chữ, màn hình chỉ toàn màu đen trong lúc chạy. Dùng kỹ
thuật **NeoSpring** (WebKit GPU process). Không jailbreak, không cần máy
tính sau khi cài.

> **Đã xác nhận chạy trên iOS 27.2.1** — test thật 15/11/2026 trên
> iPhone 17 Pro Max: bấm RESPRING (bản v1.0.0) là respring được luôn.
> AirCard-iOS ghi đã test tới **iOS 27.2 beta 2**; từ 27.2 beta 3 Apple
> vá đường `airlift` (đường truyền file, không phải NeoSpring).
> - App này **không hứa chắc chắn respring được trên 27.2.1**. Nó thử
>   NeoSpring một cách trung thực, ghi log đầy đủ, và nếu không được thì
>   hiện bảng lỗi với nút thử lại + hướng dẫn respring bằng tay
>   (Display Zoom). Đừng kỳ vọng 100%.
> - **Chưa có file IPA trong repo này.** Môi trường làm project là Linux,
>   không có Xcode nên không biên dịch được IPA. IPA chưa ký được build
>   bằng GitHub Actions (xem dưới) — **không có IPA giả** trong repo.

## Vì sao không dùng RespringApp cũ?

File `respringapp.ipa` (34306/mdc0, bundle `com.respring.app`) thực chất
là binary PosterBoard nội bộ của Apple (iOS 16.6 internal SDK) đóng gói
lại, chỉ chạy tới iOS 27.0, đã bị chặn ở 27.1/27.2. Project này không vá
file đó — nó đổi sang cơ chế NeoSpring.

## NeoSpring hoạt động thế nào? (tóm tắt)

1. App mở một `WKWebView` toàn màn hình, bật JavaScript, dùng
   non-persistent data store (không để lại dữ liệu web).
2. Chỉ start payload **sau khi** web view đã gắn vào cửa sổ và có kích
   thước thật (không start khi surface còn 0×0), rồi flush
   `CATransaction`.
3. Payload (HTML/JS) chạy trong một iframe sandboxed, tạo workload nặng
   cho WebKit GPU process — cụ thể là hàng trăm layer dùng
   `backdrop-filter: blur()` với perspective/transform cực lớn, kèm
   `navigator.share` với text dài và `crypto.getRandomValues` cấp phát
   liên tục. GPU process quá tải → SpringBoard reload (respring).
4. Timeout: 10 giây nếu chưa start được, 20 giây sau khi đã start —
   quá hạn thì dừng và báo timeout (kỹ thuật này không có callback
   thành công, vì nếu thành công thì SpringBoard đã restart rồi).
5. Hủy được bất cứ lúc nào: gọi `window.stopNeoSpring()`, dừng web view.

Chi tiết đầy đủ: `Respring/NeoSpring.swift` (có comment nguồn + credit).
Credit: kỹ thuật @neonmodder123, Swift @skadz108, dự án NeoSpring
@rooootdev — https://github.com/rooootdev/neospring. Harness tham chiếu
từ GestaltX (GPL-3.0).

## ⚠️ Payload NeoSpring — đã có payload thật

File `Respring/NeoSpringPayload.html` hiện chứa **payload thật** lấy từ
chuỗi `document` trong `GestaltX/NeoSpringView.swift` (GPL-3.0,
commit `9984e6a`, 2.397 byte, định nghĩa `window.startNeoSpring()` /
`window.stopNeoSpring()`). App kiểm tra và báo "Chưa có payload" nếu
file bị thay bằng placeholder.

Muốn thay payload khác, thay toàn bộ nội dung file đó bằng tài liệu HTML
NeoSpring từ nguồn upstream, tài liệu đó phải định nghĩa:
- `window.startNeoSpring()` — bắt đầu workload
- `window.stopNeoSpring()` — dừng workload

Lấy ở một trong hai chỗ:
1. Dự án NeoSpring gốc: https://github.com/rooootdev/neospring
2. Chuỗi `document` trong file `GestaltX/NeoSpringView.swift` của
   GestaltX: https://github.com/huamidev/GestaltX (GPL-3.0 — nếu dùng
   bản này thì app build ra vẫn thuộc GPL-3.0, đúng như license của
   project này).

## Build IPA chưa ký

### Cách 1 — GitHub Actions (khuyên dùng, không cần Mac)
1. Đưa repo này lên GitHub của bạn (repo riêng cũng được).
2. Vào tab **Actions** → **Build unsigned IPA** → **Run workflow**
   (hoặc push tag `v1.0.0`).
3. Chờ chạy xong → tải artifact **Respring27-unsigned-ipa** →
   file `Respring27-unsigned.ipa`.
4. Workflow dùng runner `macos-26`, Xcode 26, cài XcodeGen bằng brew,
   chạy `build-ipa.sh`, upload IPA. Xem file
   `.github/workflows/build-ipa.yml`.

### Cách 2 — Build trên Mac (Xcode 16+)
```bash
brew install xcodegen
bash build-ipa.sh
# Kết quả: build/Respring27-unsigned.ipa
```
Script sẽ: `xcodegen generate` → `xcodebuild archive` với
`CODE_SIGNING_ALLOWED=NO` → đóng gói `Payload/Respring27.app` thành IPA.

## Cài bằng Feather (tự ký, không cần đưa chứng chỉ cho ai)

> **Không cần upload chứng chỉ cho ai cả — và đừng bao giờ gửi file
> chứng chỉ (.p12) hay mật khẩu của nó qua chat.** Feather ký ngay trên
> iPhone của bạn, chứng chỉ không rời khỏi máy bạn.

1. Mở Feather trên iPhone → mục **Sign** / ký app: import file
   `Respring27-unsigned.ipa`.
2. Chọn chứng chỉ Apple Developer trả phí của bạn để ký (Feather sẽ
   resign, bundle ID `com.harry.respring2721` — đổi được trong Feather
   nếu trùng).
3. Bấm **Install** → ra màn hình chính, mở app.
4. Nếu iOS báo "Untrusted Enterprise Developer": vào Cài đặt →
   Cài đặt chung → Quản lý thiết bị / VPN & Thiết bị → tin cậy chứng
   chỉ của bạn, rồi mở lại app.

## Cách dùng

1. **Sao lưu iPhone trước** (iCloud hoặc máy tính).
2. Mở app **Respring 27** — app tự respring luôn, không cần bấm gì,
   màn hình chỉ toàn màu đen trong lúc chạy.
3. Đợi tối đa ~20 giây: nếu thành công, màn hình đen vài giây rồi về
   Màn hình khóa — xong.
4. Nếu app hiện bảng lỗi (timeout / không có payload / lỗi): bấm
   **THỬ LẠI** trong bảng đó, rồi dùng nút **"Cách khác nếu không
   respring được"**:
   - **Display Zoom** (chắc ăn nhất): Cài đặt → Màn hình & Độ sáng →
     Thu phóng màn hình → đổi qua lại → Áp dụng.
   - **Kéo widget** (iOS 27.0/27.0.1, trên 27.2.1 chưa xác nhận): giữ
     widget Đồng hồ kéo nhanh qua các trang trong khi giữ nút Sườn.
     Có thể đơ máy — xem hướng dẫn force restart trong app.
5. Nếu màn hình đơ quá 30 giây: force restart — bấm nhả Tăng âm lượng
   → bấm nhả Giảm âm lượng → giữ nút Sườn tới khi hiện logo Apple.

## Cấu trúc project

```
respring-2721/
├── README.md                    # file này
├── LICENSE                      # GNU GPL v3
├── THIRD_PARTY_NOTICES.md       # credit NeoSpring / GestaltX / AirCard
├── Logo-goc.jpg                 # logo gốc user gửi (xanh lá + spinner trắng)
├── project.yml                  # XcodeGen — sinh .xcodeproj
├── build-ipa.sh                 # build IPA chưa ký trên Mac
├── .github/workflows/build-ipa.yml   # build IPA chưa ký trên GitHub Actions
└── Respring/
    ├── RespringApp.swift        # entry point
    ├── ContentView.swift        # không giao diện: mở app là tự chạy; chỉ hiện bảng lỗi khi thất bại
    ├── NeoSpring.swift          # harness WKWebView NeoSpring + model + timeout
    ├── NeoSpringPayload.html    # PLACEHOLDER — thay bằng payload thật (xem trên)
    ├── FallbackGuide.swift      # hướng dẫn Display Zoom + kéo widget
    ├── Info.plist               # bundle com.harry.respring2721, iOS 17.0+
    ├── Respring27.entitlements  # trống — app không cần entitlement nào
    └── Assets.xcassets/
        └── AppIcon.appiconset/  # icon từ logo user gửi (9 size: 40–1024)
```

- Deployment target: iOS 17.0. Swift 5. Xcode 16+.
- Logo: file user gửi (nền xanh lá gradient, spinner trắng 8 vạch),
  resize bằng PIL giữ nguyên thiết kế, không thêm chữ. Gốc 512×512 nên
  bản 1024×1024 là upscale — hơi mềm, nhưng vẫn là đúng logo của bạn.
- Entitlements: **không có gì** — app không xin entitlement private
  nào (`platform-application` v.v. chứng chỉ Developer không cấp được).

## Cảnh báo

- Kỹ thuật này cố tình làm SpringBoard restart. Chỉ dùng trên máy của
  chính bạn, đã sao lưu, không chạy khi máy đang làm việc quan trọng.
- Màn hình có thể nhấp nháy khi respring — người nhạy cảm với ánh sáng
  nhấp nháy không nên thử cách kéo widget.
- Tác giả project không chịu trách nhiệm nếu máy bootloop / mất dữ liệu.
  Dùng Display Zoom nếu bạn muốn cách an toàn tuyệt đối.

## Giấy phép

GNU General Public License v3 — xem `LICENSE`. Credit đầy đủ trong
`THIRD_PARTY_NOTICES.md`.
