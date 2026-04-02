# TRSSDownloader

TRSSDownloader, Minecraft screenshare toplulukları için gerekli araçları ve PowerShell scriptlerini tek yerden indirip düzenli şekilde yönetmeyi kolaylaştıran PowerShell tabanlı bir downloader aracıdır.

Bu proje, tek tek link arama ve klasör düzenleme uğraşını azaltmak için yapıldı. Amaç; sık kullanılan SS araçlarını, yardımcı scriptleri ve çeşitli kontrolleri daha hızlı erişilebilir hale getirmektir.

## Özellikler

- Kategorilere ayrılmış araç listesi
- PowerShell scriptleri için ayrı bölüm
- Tek yerden hızlı indirme
- Düzenli klasör yapısı
- Basit ve hızlı kullanım

## Kullanım

CMD üzerinden aşağıdaki komutu çalıştır:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; powershell Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/Boboalover/TRSSDownloader/refs/heads/main/TRSS-Downloader.ps1")
