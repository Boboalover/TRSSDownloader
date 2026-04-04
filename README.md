# TRSSDownloader

TRSSDownloader, Minecraft screenshare toplulukları için gerekli araçları ve PowerShell scriptlerini tek yerden indirip düzenli şekilde yönetmeyi kolaylaştıran PowerShell tabanlı bir downloader aracıdır.

Bu proje, tek tek link arama ve klasör düzenleme uğraşını azaltmak için yapıldı. Amaç; sık kullanılan SS araçlarını, yardımcı scriptleri ve çeşitli kontrolleri daha hızlı erişilebilir hale getirmektir.

## Özellikler

- Kategorilere ayrılmış araç listesi
- PowerShell scriptleri için ayrı bölüm
- Tek yerden hızlı indirme
- Düzenli klasör yapısı
- Basit ve hızlı kullanım

### Credits
- [Mehmetyll](https://github.com/Mehmetyll) özel teşekkürler. GUI de çok yardımcı oldu ve kendisi olmasa bu script olmazdı
- [Einfrieren](https://github.com/korkusuzadX) önceki toolun yapımcısı ve yine yardımı dokundu

## Kullanım

CMD üzerinden aşağıdaki komutu çalıştır:

```
powershell -Command "IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Boboalover/TRSSDownloader/main/TRSS-Downloader.ps1')"
