# Respring

App respring cho iOS 27.2.1 — **mở app là tự respring luôn, không có
giao diện, không nút, không chữ**. Chỉ cần bấm vào icon app.

> **Đã xác nhận chạy trên iOS 27.2.1** — test thật ngày 15/11/2026 trên
> iPhone 17 Pro Max. Không jailbreak, không cần máy tính sau khi cài.

## Tải về

- **v1.0** — file `RespringApp.ipa` ở mục
  [Releases](https://github.com/nguyenthanhhuy88-collab/respring-2721/releases/tag/v1.0).
- File IPA **chưa ký**: ký bằng Feather (hoặc AltStore) với chứng chỉ
  Apple Developer của bạn rồi cài lên máy. **Không gửi chứng chỉ
  (.p12) hay mật khẩu của nó cho ai cả** — Feather ký ngay trên
  iPhone của bạn.

## App làm gì?

App mở một `WKWebView` toàn màn hình chạy payload NeoSpring: workload
nặng cho WebKit GPU process khiến SpringBoard reload (respring).

- Kỹ thuật WebKit GPU respring: @neonmodder123
- Swift implementation: @skadz108
- Dự án NeoSpring: @rooootdev — https://github.com/rooootdev/neospring
- Harness tham chiếu: GestaltX (GPL-3.0) — https://github.com/huamidev/GestaltX
- Payload HTML/JS trong app lấy từ chuỗi `document` trong
  `GestaltX/NeoSpringView.swift`.

Chi tiết đầy đủ: `Respring/NeoSpring.swift` (có comment nguồn + credit).

## Vì sao không dùng app Respring cũ?

File `respringapp.ipa` (34306/mdc0, bundle `com.respring.app`) thực
chất là binary PosterBoard nội bộ của Apple (iOS 16.6 internal SDK)
đóng gói lại, chỉ chạy tới iOS 27.0, đã bị chặn ở 27.1/27.2. App này
không vá file đó — nó đổi sang cơ chế NeoSpring.

## Tự build IPA chưa ký

### Cách 1 — GitHub Actions (không cần Mac)

1. Fork repo này.
2. Tab **Actions** → **Build unsigned IPA** → **Run workflow**.
3. Chờ chạy xong → tải artifact **Respring27-unsigned-ipa**.

### Cách 2 — Trên Mac (Xcode 16+)

```bash
brew install xcodegen
bash build-ipa.sh
# Kết quả: build/Respring27-unsigned.ipa
```

Script sẽ: `xcodegen generate` → `xcodebuild archive` với
`CODE_SIGNING_ALLOWED=NO` → đóng gói `Payload/Respring27.app` thành IPA.

## Cấu trúc project

```
respring-2721/
├── README.md                    # file này
├── LICENSE                      # GNU GPL v3
├── THIRD_PARTY_NOTICES.md       # credit NeoSpring / GestaltX / AirCard
├── Logo-goc.jpg                 # logo gốc (xanh lá + spinner trắng)
├── project.yml                  # XcodeGen — sinh .xcodeproj
├── build-ipa.sh                 # build IPA chưa ký trên Mac
├── .github/workflows/build-ipa.yml   # build IPA chưa ký trên GitHub Actions
└── Respring/
    ├── RespringApp.swift        # entry point
    ├── ContentView.swift        # không giao diện: mở app là tự chạy
    ├── NeoSpring.swift          # harness WKWebView NeoSpring + model + timeout
    ├── NeoSpringPayload.html    # payload thật (GestaltX, GPL-3.0)
    ├── Info.plist               # bundle com.harry.respring2721, iOS 17.0+
    ├── Respring27.entitlements  # trống — app không cần entitlement nào
    └── Assets.xcassets/
        └── AppIcon.appiconset/  # icon từ logo (9 size: 40–1024)
```

- Deployment target: iOS 17.0. Swift 5. Xcode 16+.
- Entitlements: **không có gì** — app không xin entitlement private nào.

## Cảnh báo

- **Sao lưu iPhone trước khi dùng** (iCloud hoặc máy tính).
- Kỹ thuật này cố tình làm SpringBoard restart. Chỉ dùng trên máy của
  chính bạn, không chạy khi máy đang làm việc quan trọng.
- Màn hình có thể nhấp nháy khi respring.
- Nếu màn hình đơ quá 30 giây: force restart — bấm nhả Tăng âm lượng
  → bấm nhả Giảm âm lượng → giữ nút Sườn tới khi hiện logo Apple.
- Tác giả project không chịu trách nhiệm nếu máy gặp sự cố.

## Giấy phép

GNU General Public License v3 — xem `LICENSE`. Credit đầy đủ trong
`THIRD_PARTY_NOTICES.md`.
