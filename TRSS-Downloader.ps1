[CmdletBinding()]
param()

Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName System.Windows.Forms

$global:toolsRoot = Join-Path ([System.Environment]::GetFolderPath("MyDocuments")) "SSTools"

$global:toolList = @(
    [PSCustomObject]@{Url="https://www.nirsoft.net/utils/winprefetchview-x64.zip";Ad="WinPrefetchView_x64.zip";Klasor="NirSoft";Tip="zip";Aciklama="Prefetch dosyalarini goruntuler"}
    [PSCustomObject]@{Url="https://www.nirsoft.net/utils/lastactivityview.zip";Ad="LastActivityView.zip";Klasor="NirSoft";Tip="zip";Aciklama="Son kullanici aktivitelerini listeler"}
    [PSCustomObject]@{Url="https://www.nirsoft.net/utils/usbdrivelog.zip";Ad="UsbDriveLog.zip";Klasor="NirSoft";Tip="zip";Aciklama="USB surucu gecmisini gosterir"}
    [PSCustomObject]@{Url="https://www.nirsoft.net/utils/windeflogview.zip";Ad="WinDefLogView.zip";Klasor="NirSoft";Tip="zip";Aciklama="Windows Defender log goruntuleyici"}
    [PSCustomObject]@{Url="https://www.nirsoft.net/utils/shellbagsview.zip";Ad="ShellBagsView.zip";Klasor="NirSoft";Tip="zip";Aciklama="Shell bags / klasor gecmisi"}
    [PSCustomObject]@{Url="https://www.nirsoft.net/utils/uninstallview-x64.zip";Ad="UninstallView_x64.zip";Klasor="NirSoft";Tip="zip";Aciklama="Kaldirilan programlari listeler"}
    [PSCustomObject]@{Url="https://www.nirsoft.net/utils/loadeddllsview-x64.zip";Ad="LoadedDllsView_x64.zip";Klasor="NirSoft";Tip="zip";Aciklama="Yuklu DLL listesi"}
    [PSCustomObject]@{Url="https://www.nirsoft.net/utils/jumplistsview.zip";Ad="JumpListsView.zip";Klasor="NirSoft";Tip="zip";Aciklama="Jump list gecmisi"}
    [PSCustomObject]@{Url="https://www.nirsoft.net/utils/clipboardic.zip";Ad="Clipboardic.zip";Klasor="NirSoft";Tip="zip";Aciklama="Pano gecmisini goruntuler"}
    [PSCustomObject]@{Url="https://download.ericzimmermanstools.com/net9/TimelineExplorer.zip";Ad="TimelineExplorer.zip";Klasor="EricZimmerman";Tip="zip";Aciklama="Zaman cizelgesi analizi"}
    [PSCustomObject]@{Url="https://download.ericzimmermanstools.com/SrumECmd.zip";Ad="SrumECmd.zip";Klasor="EricZimmerman";Tip="zip";Aciklama="SRUM veritabani ayristirici"}
    [PSCustomObject]@{Url="https://download.ericzimmermanstools.com/AmcacheParser.zip";Ad="AmcacheParser.zip";Klasor="EricZimmerman";Tip="zip";Aciklama="Amcache analiz araci"}
    [PSCustomObject]@{Url="https://download.ericzimmermanstools.com/net6/WxTCmd.zip";Ad="WxTCmd.zip";Klasor="EricZimmerman";Tip="zip";Aciklama="Windows Timeline veritabani"}
    [PSCustomObject]@{Url="https://download.ericzimmermanstools.com/net9/RegistryExplorer.zip";Ad="RegistryExplorer.zip";Klasor="EricZimmerman";Tip="zip";Aciklama="Registry gezgini"}
    [PSCustomObject]@{Url="https://download.ericzimmermanstools.com/net9/MFTECmd.zip";Ad="MFTECmd.zip";Klasor="EricZimmerman";Tip="zip";Aciklama="MFT dosya sistemi ayristirici"}
    [PSCustomObject]@{Url="https://download.ericzimmermanstools.com/JLECmd.zip";Ad="JLECmd.zip";Klasor="EricZimmerman";Tip="zip";Aciklama="JumpList CSV olarak parselar"}
    [PSCustomObject]@{Url="https://download.ericzimmermanstools.com/net9/JumpListExplorer.zip";Ad="JumpListExplorer.zip";Klasor="EricZimmerman";Tip="zip";Aciklama="JumpList GUI ile parselar"}
    [PSCustomObject]@{Url="https://github.com/spokwn/BAM-parser/releases/download/v1.2.9/BAMParser.exe";Ad="BAMParser.exe";Klasor="Spokwn";Tip="exe";Aciklama="BAM kaydi ayristirici"}
    [PSCustomObject]@{Url="https://github.com/spokwn/prefetch-parser/releases/download/v1.5.5/PrefetchParser.exe";Ad="PrefetchParser.exe";Klasor="Spokwn";Tip="exe";Aciklama="Prefetch ayristirici"}
    [PSCustomObject]@{Url="https://github.com/spokwn/process-parser/releases/download/v0.5.5/ProcessParser.exe";Ad="ProcessParser.exe";Klasor="Spokwn";Tip="exe";Aciklama="Surec bilgisi ayristirici"}
    [PSCustomObject]@{Url="https://github.com/spokwn/pcasvc-executed/releases/download/v0.8.7/PcaSvcExecuted.exe";Ad="PcaSvcExecuted.exe";Klasor="Spokwn";Tip="exe";Aciklama="PCA servisi yurutme kaydi"}
    [PSCustomObject]@{Url="https://github.com/spokwn/JournalTrace/releases/download/1.2/JournalTraceNormal.exe";Ad="JournalTraceNormal.exe";Klasor="Spokwn";Tip="exe";Aciklama="USN Journal izleme"}
    [PSCustomObject]@{Url="https://github.com/spokwn/PathsParser/releases/download/v1.2/PathsParser.exe";Ad="PathsParser.exe";Klasor="Spokwn";Tip="exe";Aciklama="Dosya yolu gecmisi"}
    [PSCustomObject]@{Url="https://github.com/spokwn/KernelLiveDumpTool/releases/download/v1.1/KernelLiveDumpTool.exe";Ad="KernelLiveDumpTool.exe";Klasor="Spokwn";Tip="exe";Aciklama="Kernel canli dump araci"}
    [PSCustomObject]@{Url="https://github.com/spokwn/Tool/releases/download/v1.1.2/espouken.exe";Ad="espouken.exe";Klasor="Spokwn";Tip="exe";Aciklama="Espouken analiz araci"}
    [PSCustomObject]@{Url="https://github.com/spokwn/BamDeletedKeys/releases/download/v1.0/BamDeletedKeys.exe";Ad="BamDeletedKeys.exe";Klasor="Spokwn";Tip="exe";Aciklama="Silinen BAM kayitlari"}
    [PSCustomObject]@{Url="https://raw.githubusercontent.com/Echo-Anticheat/Echo-Journal/main/echo-journal.exe";Ad="echo-journal.exe";Klasor="Echo";Tip="exe";Aciklama="Journal analiz araci"}
    [PSCustomObject]@{Url="https://github.com/korkusuzadX/TR-SS-AutoDownloader/raw/main/echo%20tools/echo-userassist.exe";Ad="UserAssist.exe";Klasor="Echo";Tip="exe";Aciklama="UserAssist kayit goruntuleyici"}
    [PSCustomObject]@{Url="https://github.com/korkusuzadX/TR-SS-AutoDownloader/raw/main/echo%20tools/echo-usb.exe";Ad="UsbTool.exe";Klasor="Echo";Tip="exe";Aciklama="USB kayit analiz araci"}
    [PSCustomObject]@{Url="https://github.com/Orbdiff/PrefetchView/releases/download/v1.6.6/pv++.exe";Ad="pv++.exe";Klasor="OrbDiff";Tip="exe";Aciklama="Detayli Prefetch analiz araci"}
    [PSCustomObject]@{Url="https://github.com/Orbdiff/AmcacheParser/releases/download/v1.0/AmcacheParser.exe";Ad="AmcacheParser.exe";Klasor="OrbDiff";Tip="exe";Aciklama="Detayli Amcache analiz araci"}
    [PSCustomObject]@{Url="https://github.com/Orbdiff/JARParser/releases/download/v1.2/JARParser.exe";Ad="JARParser.exe";Klasor="OrbDiff";Tip="exe";Aciklama="Basit bir JAR scanner"}
    [PSCustomObject]@{Url="https://github.com/Orbdiff/Fileless/releases/download/v1.3/fileless.exe";Ad="Fileless.exe";Klasor="OrbDiff";Tip="exe";Aciklama="Powershell izleri ile fileless arar"}
    [PSCustomObject]@{Url="https://github.com/Orbdiff/BAMReveal/releases/download/v1.3/BAMReveal.exe";Ad="BAMReveal.exe";Klasor="OrbDiff";Tip="exe";Aciklama="BAM kayitlarini goruntuler"}
    [PSCustomObject]@{Url="https://github.com/Orbdiff/DPS-Analyzer/releases/download/v1.1/dpsanalyzer.exe";Ad="OrbDiff-DPSAnalyzer.exe";Klasor="OrbDiff";Tip="exe";Aciklama="DPS analiz araci"}
    [PSCustomObject]@{Url="https://github.com/ItzIceHere/RedLotus-Mod-Analyzer/releases/download/RL/RedLotusModAnalyzer.exe";Ad="RedLotusModAnalyzer.exe";Klasor="RedLotus";Tip="exe";Aciklama="Mod analiz araci"}
    [PSCustomObject]@{Url="https://github.com/ItzIceHere/RedLotusAltChecker/releases/download/RL/RedLotusAltChecker.exe";Ad="RedLotusAltChecker.exe";Klasor="RedLotus";Tip="exe";Aciklama="Alt hesap bakma araci"}
    [PSCustomObject]@{Url="https://github.com/ItzIceHere/RedLotus-Task-Sentinel/releases/download/RL/RedLotusTaskSentinel.exe";Ad="RedLotusTaskSentinel.exe";Klasor="RedLotus";Tip="exe";Aciklama="Gorev izleyici sentinel"}
    [PSCustomObject]@{Url="https://github.com/trSScommunity/PathDuzenleyiciV2/raw/refs/heads/main/PathDuzenleyicisiV2.exe";Ad="PathDuzenleyicisiV2.exe";Klasor="TRSSCommunity";Tip="exe";Aciklama="Yol duzenleyici v2"}
    [PSCustomObject]@{Url="https://github.com/trSScommunity/MZHunter/raw/refs/heads/main/MzHunter.exe";Ad="MzHunter.exe";Klasor="TRSSCommunity";Tip="exe";Aciklama="MZ basligi tarayici"}
    [PSCustomObject]@{Url="https://github.com/Mehmetyll/Mandarin-Tool/releases/download/Mandarin-Tool/MandarinTool.jar";Ad="MandarinTool.jar";Klasor="TRSSCommunity";Tip="jar";Aciklama="Multi SS tool / JAR decompiler"}
    [PSCustomObject]@{Url="https://go.magnetforensics.com/e/52162/MagnetEncryptedDiskDetector/kpt9bg/1663239667/h/LtXFtTL-Soawv5C1oL3BIEghi7e1Lx93yesZLR--Ok0";Ad="MagnetEncryptedDiskDetector.exe";Klasor="Magnet";Tip="exe";Aciklama="Sifreli disk tespit araci"}
    [PSCustomObject]@{Url="https://go.magnetforensics.com/e/52162/mail-utm-campaign-UTMC-0000044/llr4bg/1663358653/h/4kZ9Y4i2yPRqBzuQMrywA_v5bfkpG3rG8gEiSWrYU70";Ad="MRCv120.exe";Klasor="Magnet";Tip="exe";Aciklama="RAM dump araci"}
    [PSCustomObject]@{Url="https://archive.org/download/access-data-ftk-imager-4.7.1/AccessData_FTK_Imager_4.7.1.exe";Ad="FTK_Imager_4.7.1.exe";Klasor="Forensics";Tip="exe";Aciklama="Disk imaj alma araci"}
    [PSCustomObject]@{Url="https://github.com/Yamato-Security/hayabusa/releases/download/v3.6.0/hayabusa-3.6.0-win-aarch64.zip";Ad="hayabusa-3.6.0-win-aarch64.zip";Klasor="Forensics";Tip="zip";Aciklama="Windows event log analizi"}
    [PSCustomObject]@{Url="https://github.com/Velocidex/velociraptor/releases/download/v0.75/velociraptor-v0.75.1-windows-amd64.exe";Ad="Velocidace.exe";Klasor="Forensics";Tip="exe";Aciklama="Dijital forensic platform"}
    [PSCustomObject]@{Url="https://github.com/winsiderss/si-builds/releases/download/3.2.25275.112/systeminformer-build-canary-setup.exe";Ad="SystemInformer_Canary_Setup.exe";Klasor="SystemTools";Tip="exe";Aciklama="Gelismis sistem monitoru"}
    [PSCustomObject]@{Url="https://www.voidtools.com/Everything-1.4.1.1029.x86-Setup.exe";Ad="Everything-Setup.exe";Klasor="SystemTools";Tip="exe";Aciklama="Anlik dosya arama motoru"}
    [PSCustomObject]@{Url="https://github.com/NotRequiem/InjGen/releases/download/v2.0/InjGen.exe";Ad="InjGen.exe";Klasor="Analysis";Tip="exe";Aciklama="Enj eksiyon tespit araci"}
    [PSCustomObject]@{Url="https://github.com/deathmarine/Luyten/releases/download/v0.5.4_Rebuilt_with_Latest_depenencies/luyten-0.5.4.exe";Ad="Luyten.exe";Klasor="Analysis";Tip="exe";Aciklama="Java decompiler"}
    [PSCustomObject]@{Url="https://github.com/nay-cat/dpsanalyzer/releases/download/1.3/dpsanalyzer.exe";Ad="dpsanalyzer.exe";Klasor="Analysis";Tip="exe";Aciklama="DPS analiz araci"}
    [PSCustomObject]@{Url="https://github.com/horsicq/DIE-engine/releases/download/3.09/die_win64_portable_3.09_x64.zip";Ad="DIE_engine_portable.zip";Klasor="Analysis";Tip="zip";Aciklama="Detect-It-Easy PE analiz"}
    [PSCustomObject]@{Url="https://github.com/nay-cat/Jarabel/releases/download/light/Jarabel.Light.exe";Ad="Jarabel.Light.exe";Klasor="Misc";Tip="exe";Aciklama="JAR analiz araci"}
    [PSCustomObject]@{Url="https://github.com/RRancio/Exec/raw/main/Files/Unicode.exe";Ad="Unicode.exe";Klasor="Misc";Tip="exe";Aciklama="Unicode karakter analizi"}
    [PSCustomObject]@{Url="https://github.com/ponei/CachedProgramsList/releases/download/1.1/CachedProgramsList.exe";Ad="CachedProgramsList.exe";Klasor="Misc";Tip="exe";Aciklama="Onbellek program listesi"}
    [PSCustomObject]@{Url="https://github.com/santiagolin/TimeChangeDetect/releases/download/1.0/TimeChangeDetect.exe";Ad="TimeChangeDetect.exe";Klasor="Misc";Tip="exe";Aciklama="Sistem saati degisim tespiti"}
    [PSCustomObject]@{Url="https://github.com/MeowTonynoh/MeowNovowareFucker/raw/refs/heads/main/MeowNovowareFucker.exe";Ad="MeowNovowareFucker.exe";Klasor="Misc";Tip="exe";Aciklama="Novoware client tespit edici"}
    [PSCustomObject]@{Url="https://github.com/MeowTonynoh/MeowDoomsdayFucker/raw/refs/heads/main/MeowDoomsdayFucker.exe";Ad="MeowDoomsdayFucker.exe";Klasor="Misc";Tip="exe";Aciklama="Doomsday client tespit edici"}
    [PSCustomObject]@{Url="https://github.com/praiselily/HardlinkFinder/releases/download/Tools/hardlink.exe";Ad="HardlinkFinder.exe";Klasor="Misc";Tip="exe";Aciklama="Hardlink tespiti"}
)

$global:psList = @(
    [PSCustomObject]@{Ad="TR SS Auto Downloader";Aciklama="Turk SS toplulugu orijinal otomatik indirici scripti";Yazar="korkusuzadX";Url="https://raw.githubusercontent.com/korkusuzadX/TR-SS-AutoDownloader/main/TR_SS_Auto_Downloader.ps1";Renk="Mor"}
    [PSCustomObject]@{Ad="TR SS REG Checker";Aciklama="Turk SS toplulugu basit registry scripti";Yazar="boboalover";Url="https://github.com/Boboalover/TRSS-Simple-Registry-Checker/raw/refs/heads/main/TRSS-regchecker.ps1";Renk="Mor"}
    [PSCustomObject]@{Ad="TR SS Macro Checker";Aciklama="Turk SS toplulugu basit mouse profile checker";Yazar="boboalover";Url="https://github.com/Boboalover/TRSS-mouse-macro-checker/raw/refs/heads/main/TRSSmacroChecker.ps1";Renk="Mor"}
    [PSCustomObject]@{Ad="Faker Detection";Aciklama="FakerFinder";Yazar="Praiselily";Url="https://raw.githubusercontent.com/praiselily/WeHateFakers/refs/heads/main/HotspotLogs.ps1";Renk="Mavi"}
    [PSCustomObject]@{Ad="JAR Scanner";Aciklama="JAR Scanner";Yazar="Praiselily";Url="https://raw.githubusercontent.com/praiselily/JARScanner/refs/heads/main/JARScanner.ps1";Renk="Mavi"}
    [PSCustomObject]@{Ad="Service Enabler";Aciklama="Servis acma scripti";Yazar="Praiselily";Url="https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Service-Enabler.ps1";Renk="Mavi"}
    [PSCustomObject]@{Ad="Services";Aciklama="Gerekli Servislere bakar";Yazar="Praiselily";Url="https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Services.ps1";Renk="Mavi"}
    [PSCustomObject]@{Ad="BAM Parser";Aciklama="BAM kayitlarina bakar";Yazar="spokwn";Url="https://raw.githubusercontent.com/spokwn/powershells/refs/heads/main/bamparser.ps1";Renk="Kirmizi"}
    [PSCustomObject]@{Ad="DoomsDay Finderv2";Aciklama="Prefetch kullanarak DoomsDay client arar";Yazar="zedoonvm1";Url="https://raw.githubusercontent.com/zedoonvm1/powershell-scripts/refs/heads/main/DoomsDayDetector.ps1";Renk="Mavi"}
)

$global:katColor = @{
    "NirSoft"="#60A5FA"
    "EricZimmerman"="#A855F7"
    "Spokwn"="#FB923C"
    "Echo"="#38E0F8"
    "RedLotus"="#FB7185"
    "OrbDiff"="#9AA34B"
    "TRSSCommunity"="#F85858"
    "Magnet"="#818CF8"
    "Forensics"="#2DD4BF"
    "SystemTools"="#9CA3AF"
    "Analysis"="#F472B6"
    "Misc"="#A3A3A3"
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="SS Tools" Height="760" Width="1120" WindowStyle="None"
        AllowsTransparency="True" Background="Transparent" WindowStartupLocation="CenterScreen" FontFamily="Segoe UI">
    
    <Window.Resources>
        <SolidColorBrush x:Key="BgBrush" Color="#0A0A0F" />
        <SolidColorBrush x:Key="PanelBrush" Color="#13131C" />
        <SolidColorBrush x:Key="CardBrush" Color="#1C1C28" />
        <SolidColorBrush x:Key="HoverCardBrush" Color="#282838" />
        <SolidColorBrush x:Key="AccentBrush" Color="#8150FF" />
        <SolidColorBrush x:Key="HoverBrush" Color="#9A72FF" />
        <SolidColorBrush x:Key="TextMainBrush" Color="#F5F8FF" />
        <SolidColorBrush x:Key="TextDimBrush" Color="#8B95A8" />
        <SolidColorBrush x:Key="SuccessBrush" Color="#4ADEA0" />
        <SolidColorBrush x:Key="ErrorBrush" Color="#F85858" />

        <Style x:Key="NavBtnStyle" TargetType="RadioButton">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="RadioButton">
                        <Border x:Name="border" Background="Transparent" CornerRadius="8" Margin="8,4" Padding="20,12" Cursor="Hand">
                            <ContentPresenter VerticalAlignment="Center" HorizontalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#1A1A26"/>
                            </Trigger>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#20202F"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="PrimaryBtn" TargetType="Button">
            <Setter Property="Background" Value="{StaticResource AccentBrush}"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="6">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="15,8"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="{StaticResource HoverBrush}"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="border" Property="Opacity" Value="0.5"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="WinBtn" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{StaticResource TextDimBrush}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#252536"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="WinCloseBtn" TargetType="Button" BasedOn="{StaticResource WinBtn}">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#E81123"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    
    <Border Background="{StaticResource BgBrush}" CornerRadius="12" ClipToBounds="True" BorderBrush="#202030" BorderThickness="1">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="40"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="130"/>
            </Grid.RowDefinitions>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="250"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            
            <Border Grid.Row="0" Grid.ColumnSpan="2" Background="{StaticResource PanelBrush}" x:Name="TitleBar">
                <Grid>
                    <StackPanel Orientation="Horizontal" Margin="15,0,0,0">
                        <TextBlock Text="TRSS" Foreground="{StaticResource AccentBrush}" FontWeight="Bold" FontSize="15" VerticalAlignment="Center"/>
                        <TextBlock Text="TOOLS" Foreground="#C0C0D0" FontWeight="SemiBold" FontSize="12" VerticalAlignment="Center" Margin="6,0,0,0"/>
                        <TextBlock Text="v2.6" Foreground="#555" FontSize="10" VerticalAlignment="Center" Margin="10,2,0,0"/>
                    </StackPanel>
                    
                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                        <Button x:Name="BtnMin" Content="—" Style="{StaticResource WinBtn}" Width="45"/>
                        <Button x:Name="BtnMax" Content="◻" Style="{StaticResource WinBtn}" Width="45"/>
                        <Button x:Name="BtnClose" Content="✕" Style="{StaticResource WinCloseBtn}" Width="45"/>
                    </StackPanel>
                    <Border VerticalAlignment="Bottom" Height="1" Background="#1A1A26"/>
                </Grid>
            </Border>

            <Border Grid.Row="1" Grid.Column="0" Background="{StaticResource PanelBrush}">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="70"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    
                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,15,0,0">
                        <RadioButton x:Name="TabAraclar" Content="Araclar" Style="{StaticResource NavBtnStyle}" IsChecked="True" Foreground="{StaticResource TextMainBrush}" FontSize="14"/>
                        <RadioButton x:Name="TabScriptler" Content="Scriptler" Style="{StaticResource NavBtnStyle}" Foreground="{StaticResource TextDimBrush}" FontSize="14"/>
                    </StackPanel>
                    
                    <ScrollViewer Grid.Row="1" Margin="0,10,0,0" Padding="10,0" VerticalScrollBarVisibility="Auto">
                        <StackPanel x:Name="CategoryList"/>
                    </ScrollViewer>

                    <Border Grid.RowSpan="2" HorizontalAlignment="Right" Width="1" Background="#1A1A26"/>
                </Grid>
            </Border>

            <ScrollViewer x:Name="MainScroller" Grid.Row="1" Grid.Column="1" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" Padding="20">
                <Grid x:Name="MainContainer">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    
                    <Grid Margin="10,5,10,20">
                        <StackPanel HorizontalAlignment="Left" VerticalAlignment="Center">
                            <TextBlock x:Name="CatTitle" Text="Genel Bakis" FontSize="28" FontWeight="Bold" Foreground="White"/>
                            <TextBlock x:Name="CatDesc" Text="Sol menuden bir arac kategorisi veya script secin." FontSize="13" Foreground="{StaticResource TextDimBrush}" Margin="0,6,0,0"/>
                        </StackPanel>
                        <Button x:Name="BtnDownloadCat" Content="Kategoriyi Indir" Style="{StaticResource PrimaryBtn}" HorizontalAlignment="Right" VerticalAlignment="Center" Padding="20,10" Visibility="Collapsed"/>
                    </Grid>
                    
                    <WrapPanel x:Name="ItemsContainer" Grid.Row="1" ItemWidth="400" Margin="0"/>
                </Grid>
            </ScrollViewer>

            <Border Grid.Row="2" Grid.ColumnSpan="2" Background="{StaticResource PanelBrush}">
                <Border.Effect>
                    <DropShadowEffect Color="Black" BlurRadius="10" ShadowDepth="0" Opacity="0.4" Direction="90"/>
                </Border.Effect>
                <Grid Margin="25,15,25,20">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="30"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    
                    <StackPanel Grid.Column="0" VerticalAlignment="Center">
                        <TextBlock x:Name="StatusLabel" Text="Hazir." Foreground="{StaticResource TextDimBrush}" FontSize="13" Margin="0,0,0,10"/>
                        <Border Height="6" Background="#1C1C28" CornerRadius="3" ClipToBounds="True">
                             <Border x:Name="ProgBar" HorizontalAlignment="Left" Width="0" Background="{StaticResource AccentBrush}" CornerRadius="3"/>
                        </Border>
                        <Box x:Name="LogBox" Height="65" Background="Transparent" BorderThickness="0" Margin="0,12,0,0" Foreground="{StaticResource TextDimBrush}" FontFamily="Consolas" FontSize="12" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="NoWrap"/>
                    </StackPanel>
                    
                    <StackPanel Grid.Column="2" VerticalAlignment="Center">
                        <Button x:Name="BtnDownloadAll" Content="HEPSINI INDIR" Style="{StaticResource PrimaryBtn}" Margin="0,0,0,12" Height="45" Width="250" FontSize="14"/>
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                            <Button x:Name="BtnOpenFolder" Content="Klasoru Ac" Background="#20202F" Foreground="White" BorderThickness="0" Padding="20,8" Margin="0,0,10,0" Cursor="Hand">
                                <Button.Resources>
                                    <Style TargetType="Border">
                                        <Setter Property="CornerRadius" Value="6"/>
                                    </Style>
                                </Button.Resources>
                            </Button>
                            <Button x:Name="BtnRefresh" Content="Yenile" Background="#20202F" Foreground="White" BorderThickness="0" Padding="20,8" Cursor="Hand">
                                <Button.Resources>
                                    <Style TargetType="Border">
                                        <Setter Property="CornerRadius" Value="6"/>
                                    </Style>
                                </Button.Resources>
                            </Button>
                        </StackPanel>
                    </StackPanel>
                    <Border VerticalAlignment="Top" Height="1" Background="#1A1A26" Grid.ColumnSpan="3"/>
                </Grid>
            </Border>
        </Grid>
    </Border>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$window.FindName("TitleBar").Add_MouseLeftButtonDown({ $window.DragMove() })
$window.FindName("BtnClose").Add_Click({ $window.Close() })
$window.FindName("BtnMax").Add_Click({ 
    if ($window.WindowState -eq 'Maximized') { $window.WindowState = 'Normal' }
    else { $window.WindowState = 'Maximized' }
})
$window.FindName("BtnMin").Add_Click({ $window.WindowState = 'Minimized' })

$global:LogBox = $window.FindName("LogBox")
$global:StatusLabel = $window.FindName("StatusLabel")
$global:ProgBar = $window.FindName("ProgBar")
$global:ProgBorder = $global:ProgBar.Parent
$global:ItemsContainer = $window.FindName("ItemsContainer")
$global:CategoryList = $window.FindName("CategoryList")
$global:CatTitle = $window.FindName("CatTitle")
$global:CatDesc = $window.FindName("CatDesc")
$global:BtnDownloadCat = $window.FindName("BtnDownloadCat")
$global:BtnDownloadAll = $window.FindName("BtnDownloadAll")

$global:bc = New-Object System.Windows.Media.BrushConverter

function Write-Log {
    param($m)
    $ts = Get-Date -Format "HH:mm:ss"
    $global:LogBox.AppendText("[$ts] $m`n")
    $global:LogBox.ScrollToEnd()
    [System.Windows.Forms.Application]::DoEvents()
}

function Update-Progress {
    param($val, $max)
    $w = $global:ProgBorder.ActualWidth
    if ($max -gt 0) {
        $global:ProgBar.Width = [Math]::Max(0, [Math]::Min($w, ($val / $max) * $w))
    } else {
        $global:ProgBar.Width = 0
    }
    [System.Windows.Forms.Application]::DoEvents()
}

function Get-ToolStatus {
    param($tool)
    $kp = Join-Path $global:toolsRoot $tool.Klasor
    if ($tool.Tip -eq "zip") {
        $ex = Join-Path $kp ($tool.Ad -replace "\.zip$","")
        if (Test-Path $ex) { return $true }
    }
    return (Test-Path (Join-Path $kp $tool.Ad))
}

function Expand-ZipSafe {
    param($z, $d)
    try { 
        if(Test-Path $d){Remove-Item $d -Recurse -Force -EA SilentlyContinue}
        Expand-Archive $z $d -Force
        return $true
    } catch { 
        try {
            Add-Type -AN System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($z,$d)
            return $true
        } catch { return $false }
    }
}

function Start-Download {
    param($toolsList)
    $n = $toolsList.Count
    $ok = 0; $sk = 0; $er = 0
    
    $global:BtnDownloadAll.IsEnabled = $false
    $wc = New-Object System.Net.WebClient
    [void]$wc.Headers.Add("User-Agent","Mozilla/5.0")
    
    for($i=0; $i -lt $n; $i++) {
        $t = $toolsList[$i]
        $dir = Join-Path $global:toolsRoot $t.Klasor
        $dest = Join-Path $dir $t.Ad
        if (-not(Test-Path $dir)) { New-Item -ItemType Directory $dir -Force | Out-Null }
        
        if (Get-ToolStatus $t) {
            Write-Log "Mevcut: $($t.Ad)"
            $sk++
        } else {
            $global:StatusLabel.Text = "Indiriliyor ($($i+1)/$n): $($t.Ad)"
            Write-Log "Indiriliyor: $($t.Ad)"
            Update-Progress ($i+0.5) $n
            
            try {
                $wc.DownloadFile($t.Url, $dest)
                if ($t.Tip -eq "zip") {
                    $exD = Join-Path $dir ($t.Ad -replace "\.zip$","")
                    if (Expand-ZipSafe $dest $exD) {
                        Remove-Item $dest -Force -EA SilentlyContinue
                        Write-Log "  -> Ayiklandi"
                    } else {
                        Write-Log "  -> AYIKLAMA HATASI"
                    }
                }
                $ok++
                Write-Log "  -> Tamamlandi"
            } catch {
                Write-Log "  -> HATA OLUSTU: $($t.Ad)"
                $er++
                if(Test-Path $dest){Remove-Item $dest -Force -EA SilentlyContinue}
            }
        }
        Update-Progress ($i+1) $n
    }
    $wc.Dispose()
    $global:BtnDownloadAll.IsEnabled = $true
    $global:StatusLabel.Text = "Indirme Tamamlandi | Basarili: $ok | Mevcut: $sk | Hata: $er"
}

function Show-Overview {
    $global:CatTitle.Text = "Genel Bakis"
    $global:CatDesc.Text = "Minecraft Screenshare (SS) ve Windows Adli Bilisim araclarini kolayca indirin."
    $global:BtnDownloadCat.Visibility = 'Collapsed'
    $global:ItemsContainer.Children.Clear()
    
    $kategoriler = $global:toolList | Select-Object -ExpandProperty Klasor -Unique
    $totalAll = $global:toolList.Count
    $doneAll = @($global:toolList | Where-Object { Get-ToolStatus $_ }).Count

    foreach ($kat in $kategoriler) {
        $krHex = if ($global:katColor.ContainsKey($kat)) { $global:katColor[$kat] } else { "#888888" }
        $katTools = @($global:toolList | Where-Object { $_.Klasor -eq $kat })
        $kCount = $katTools.Count
        $kDone = @($katTools | Where-Object { Get-ToolStatus $_ }).Count
