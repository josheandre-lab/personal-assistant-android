# Kişisel Asistan

Modern, sade ve hızlı bir kişisel asistan uygulaması. Not alma, hatırlatma yönetimi ve günlük brifing özellikleriyle günlük hayatınızı organize edin.

## Özellikler

### 📝 Notlar
- Not oluşturma, düzenleme ve silme
- Etiketleme sistemi (#etiket)
- Başlık ve içerik arama
- Not sabitleme
- Offline özetleme (AI opsiyonel)

### ⏰ Hatırlatmalar
- Hatırlatma ekleme (başlık, açıklama, tarih-saat)
- Tekrar seçenekleri: yok, günlük, haftalık, aylık
- Yaklaşan ve gecikmiş hatırlatmalar listesi
- Yerel bildirimler
- Tamamlandı/erteleme (10dk, 1sa, 1gün)

### 📅 Günlük Brifing
- "Bugün" ekranı: günlük hatırlatmalar ve son notlar
- Tek tuşla brifing oluşturma
- Otomatik sabah brifingi (09:00, kapatılabilir)
- Paylaşma ve kopyalama

### 🎨 Tasarım
- Material 3 tasarım
- Açık/Koyu/Sistem teması
- Modern ve sade arayüz
- Türkçe dil desteği

### 🔒 Gizlilik
- Tamamen offline çalışma (varsayılan)
- Tüm veriler cihazda saklanır
- Opsiyonel AI için API anahtarı güvenli depolama

## Kurulum

### Gereksinimler
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android SDK (Android 5.0+)

### Bağımlılıkları Yükleme

```bash
cd personal_assistant
flutter pub get
```

### Isar Code Generation

```bash
flutter pub run build_runner build
```

### Çalıştırma

```bash
flutter run
```

### APK Build

Debug:
```bash
flutter build apk --debug
```

Release:
```bash
flutter build apk --release
```

App Bundle:
```bash
flutter build appbundle
```

## İzinler

Uygulama aşağıdaki izinleri gerektirir:

### Android

`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

## Proje Yapısı

```
lib/
├── main.dart                    # Uygulama giriş noktası
├── models/                      # Veri modelleri
│   ├── note_model.dart         # Not modeli (Isar)
│   ├── reminder_model.dart     # Hatırlatma modeli (Isar)
│   └── settings_model.dart     # Ayarlar modeli
├── providers/                   # Riverpod providers
│   ├── database_provider.dart  # Veritabanı providers
│   └── settings_provider.dart  # Ayarlar providers
├── screens/                     # Ekranlar
│   ├── main_screen.dart        # Ana ekran (bottom nav)
│   ├── today_screen.dart       # Bugün ekranı
│   ├── notes_screen.dart       # Notlar listesi
│   ├── note_detail_screen.dart # Not detayı
│   ├── note_edit_screen.dart   # Not düzenleme
│   ├── reminders_screen.dart   # Hatırlatmalar listesi
│   ├── reminder_detail_screen.dart # Hatırlatma detayı
│   ├── briefing_screen.dart    # Günlük brifing
│   └── settings_screen.dart    # Ayarlar
├── services/                    # Servisler
│   ├── database_service.dart   # Isar veritabanı işlemleri
│   ├── notification_service.dart # Bildirim servisi
│   ├── summary_service.dart    # Özetleme servisi
│   ├── settings_service.dart   # Ayarlar servisi
│   └── export_service.dart     # Dışa aktarma servisi
├── utils/                       # Yardımcılar
│   ├── theme.dart              # Material 3 tema
│   └── helpers.dart            # Yardımcı fonksiyonlar
└── widgets/                     # Özel widget'lar
```

## Kullanılan Teknolojiler

- **Flutter 3.0+**: UI framework
- **Dart 3.0+**: Programlama dili
- **Material 3**: Tasarım sistemi
- **Isar**: Yerel veritabanı
- **Riverpod**: State management
- **flutter_local_notifications**: Yerel bildirimler
- **flutter_secure_storage**: Güvenli depolama
- **shared_preferences**: Basit ayarlar

## AI Özetleme (Opsiyonel)

Uygulama varsayılan olarak offline çalışır. AI özelliklerini kullanmak için:

1. Ayarlar > AI Özetleme'ye gidin
2. Sağlayıcı seçin (OpenAI veya Gemini)
3. API anahtarınızı girin
4. "AI Kullan" seçeneğini aktif edin

### API Anahtarı Alma

**OpenAI:**
- [OpenAI Dashboard](https://platform.openai.com/api-keys) adresine gidin
- Yeni API anahtarı oluşturun
- Anahtarı uygulamaya yapıştırın

**Gemini:**
- [Google AI Studio](https://makersuite.google.com/app/apikey) adresine gidin
- Yeni API anahtarı oluşturun
- Anahtarı uygulamaya yapıştırın

## Kabul Test Senaryoları

### 1. Not Oluşturma
1. Uygulamayı aç
2. "Notlarım" sekmesine git
3. "Yeni Not" butonuna tıkla
4. Başlık ve içerik gir
5. Etiket ekle
6. "Kaydet" butonuna tıkla
7. Notun listelendiğini doğrula

### 2. Not Arama
1. "Notlarım" sekmesine git
2. Arama çubuğuna tıkla
3. Anahtar kelime gir
4. Sonuçların filtrelendiğini doğrula

### 3. Not Özetleme (Offline)
1. Bir not aç
2. "Özetle" butonuna tıkla
3. Özetin oluşturulduğunu doğrula
4. Özetin not detayında görüntülendiğini doğrula

### 4. Hatırlatma Oluşturma
1. "Hatırlatmalar" sekmesine git
2. "Hatırlatma Ekle" butonuna tıkla
3. Başlık ve açıklama gir
4. Tarih ve saat seç
5. Tekrar seçeneği belirle
6. "Kaydet" butonuna tıkla
7. Hatırlatmanın listelendiğini doğrula

### 5. Hatırlatma Bildirimi
1. 1 dakika sonra olacak hatırlatma oluştur
2. Uygulamayı arka plana al
3. Bildirimin geldiğini doğrula
4. Bildirime tıklayarak hatırlatmayı aç

### 6. Günlük Brifing
1. "Bugün" sekmesine git
2. "Günlük Brifing Al" butonuna tıkla
3. Brifing ekranının açıldığını doğrula
4. İçeriğin bugünün hatırlatmalarını ve son notları içerdiğini doğrula

### 7. Tema Değiştirme
1. "Ayarlar" sekmesine git
2. Tema seçeneklerinden "Koyu"yu seç
3. Uygulamanın koyu temaya geçtiğini doğrula

### 8. Veri Dışa Aktarma
1. "Ayarlar" sekmesine git
2. "Verileri Dışa Aktar" seçeneğine tıkla
3. JSON dosyasının oluşturulduğunu doğrula
4. Paylaşım diyaloğunun açıldığını doğrula

### 9. AI Özetleme (Opsiyonel)
1. Ayarlar > AI Özetleme'ye git
2. API anahtarı gir
3. Bir not aç
4. "Özetle" butonuna tıkla
5. AI tarafından oluşturulmuş özeti doğrula

### 10. Bildirim İzni
1. Uygulamayı ilk kez aç
2. Hatırlatma oluştur
3. Bildirim izni istendiğini doğrula
4. İzni reddet
5. Kullanıcının bilgilendirildiğini doğrula

## Hata Ayıklama

### Bildirimler Çalışmıyor
1. AndroidManifest.xml'de izinlerin eklendiğini kontrol et
2. Cihazın bildirim ayarlarında uygulamanın izinlerinin açık olduğunu kontrol et
3. Pil optimizasyonunun kapalı olduğundan emin ol

### Veritabanı Hataları
```bash
# Isar dosyalarını temizle
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Build Hataları
```bash
# Gradle temizle
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen önce bir issue açın ve değişikliklerinizi tartışın.

## İletişim

Sorularınız veya önerileriniz için lütfen issue açın.
