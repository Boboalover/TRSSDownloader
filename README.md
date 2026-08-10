# TRSSDownloader

TRSSDownloader, Minecraft screenshare toplulukları için gerekli araçları ve PowerShell scriptlerini tek yerden indirip düzenli şekilde yönetmeyi kolaylaştıran PowerShell tabanlı bir downloader aracıdır.

Bu proje, tek tek link arama ve klasör düzenleme uğraşını azaltmak için yapıldı. Amaç; sık kullanılan SS araçlarını, yardımcı scriptleri ve çeşitli kontrolleri daha hızlı erişilebilir hale getirmektir.

## Özellikler

- Kategorilere ayrılmış araç listesi
- PowerShell scriptleri için ayrı bölüm
- Tek yerden hızlı indirme, araç başına canlı indirme yüzdesi
- Düzenli klasör yapısı
- Basit ve hızlı kullanım
- Araç listesi `catalog.json` dosyasından okunur; depoya push atıldığı anda herkes güncel listeyi alır

## Araç listesini güncellemek

Yeni araç veya script eklemek için `TRSS-Downloader.ps1` dosyasına dokunmaya gerek yok.
Sadece [`catalog.json`](catalog.json) dosyasını düzenleyip push at:

```json
{ "klasor": "Misc", "ad": "OrnekArac.exe", "tip": "exe", "aciklama": "Ne işe yarar", "url": "https://..." }
```

`tip` alanı `exe`, `zip` veya `jar` olabilir. `zip` olanlar indirildikten sonra otomatik ayıklanır.
Uygulama açılışta katalogu GitHub'dan çeker, bu yüzden kullanıcının bir şey yapmasına gerek kalmaz.

## Kullanım

**Admin CMD** üzerinden aşağıdaki komutu çalıştır:

```
powershell -Command "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/Boboalover/TRSSDownloader/main/TRSS-Downloader.ps1')"
```

> ⚠️ Yönetici (Admin) olarak çalıştırılması gereklidir

## Araçlar

| Kategori | Araçlar |
|----------|---------|
| **NirSoft** | WinPrefetchView, LastActivityView, UsbDriveLog, WinDefLogView, ShellBagsView, UninstallView, LoadedDllsView, JumpListsView, Clipboardic |
| **EricZimmerman** | TimelineExplorer, SrumECmd, AmcacheParser, WxTCmd, RegistryExplorer, MFTECmd, JLECmd, JumpListExplorer |
| **Spokwn** | BAMParser, PrefetchParser, ProcessParser, PcaSvcExecuted, JournalTrace, PathsParser, KernelLiveDumpTool, espouken, BamDeletedKeys |
| **Echo** | Echo-Journal, UserAssist, UsbTool |
| **OrbDiff** | pv++, AmcacheParser, JARParser, Fileless, BAMReveal, DPS Analyzer |
| **RedLotus** | ModAnalyzer, AltChecker, TaskSentinel |
| **Magnet** | EncryptedDiskDetector, RAM Capture |
| **Forensics** | FTK Imager, Hayabusa, Velociraptor |
| **SystemTools** | System Informer, Everything |
| **Analysis** | InjGen, Luyten, DPS Analyzer, DIE Engine |
| **Misc** | MandarinTool, Jarabel, Unicode, CachedProgramsList, TimeChangeDetect, MeowNovowareFucker, MeowDoomsdayFucker, HardlinkFinder, MarsPixelDumpAnalyzer, RegistryScanner |

## Scriptler

| Script | Yazar |
|--------|-------|
| TR SS Auto Downloader | korkusuzadX |
| TR SS REG Checker | boboalover |
| TR SS Macro Checker | boboalover |
| Faker Detection | Praiselily |
| JAR Scanner | Praiselily |
| Service Enabler | Praiselily |
| Services | Praiselily |
| BAM Parser | spokwn |
| DoomsDay Finder v2 | zedoonvm1 |

## Credits

- [Mehmetyll](https://github.com/Mehmetyll) — özel teşekkürler. GUI'de çok yardımcı oldu ve kendisi olmasa bu script olmazdı
- [Einfrieren](https://github.com/korkusuzadX) — önceki toolun yapımcısı ve yine yardımı dokundu
