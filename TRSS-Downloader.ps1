#Requires -Version 5.1
<#
    TRSS Tools - Minecraft SS ve adli bilisim araclari indiricisi
    Arayuz: TurkishPvP tasarim dili (saf siyah zemin, tek marka kirmizisi, hairline ayrimlar)

    Arac listesi catalog.json dosyasindan okunur. Depoya her push sonrasi
    kullanicilar guncel listeyi otomatik alir; scripti degistirmek gerekmez.
#>
[CmdletBinding()]
param()

Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

$global:Surum     = "3.0"
$global:RepoRaw   = "https://raw.githubusercontent.com/Boboalover/TRSSDownloader/main"
$global:ToolsRoot = Join-Path ([System.Environment]::GetFolderPath("MyDocuments")) "SSTools"
$global:Mesgul    = $false
$global:KartRef   = @{}
$global:SonKat    = ""

# ---------------------------------------------------------------- katalog ----

function Get-Katalog {
    # once yerel dosya (depo klonuysa), sonra GitHub. Ikisi de yoksa bos katalog.
    $yerel = if ($PSScriptRoot) { Join-Path $PSScriptRoot "catalog.json" } else { $null }
    if ($yerel -and (Test-Path $yerel)) {
        try { return (Get-Content $yerel -Raw -Encoding UTF8 | ConvertFrom-Json) } catch { }
    }
    try {
        $onbellekKir = [guid]::NewGuid().ToString("N")
        return Invoke-RestMethod "$global:RepoRaw/catalog.json?v=$onbellekKir" -TimeoutSec 25
    } catch {
        return $null
    }
}

$katalog = Get-Katalog
if ($katalog) {
    $global:AracListesi   = @($katalog.araclar)
    $global:ScriptListesi = @($katalog.scriptler)
    $global:KatalogSurum  = $katalog.surum
} else {
    $global:AracListesi   = @()
    $global:ScriptListesi = @()
    $global:KatalogSurum  = "?"
}

# -------------------------------------------------------------------- XAML ---

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="TRSS Tools" Height="810" Width="1200" MinHeight="660" MinWidth="1000"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent"
        WindowStartupLocation="CenterScreen" Opacity="0"
        FontFamily="Segoe UI Variable Text, Segoe UI"
        TextOptions.TextFormattingMode="Ideal" TextOptions.TextRenderingMode="ClearType"
        UseLayoutRounding="True">

    <Window.Resources>
        <SolidColorBrush x:Key="Paper"      Color="#000000" />
        <SolidColorBrush x:Key="Elevated"   Color="#121212" />
        <SolidColorBrush x:Key="Surface"    Color="#1F1F1F" />
        <SolidColorBrush x:Key="Rule"       Color="#1C1C1C" />
        <SolidColorBrush x:Key="RuleStrong" Color="#2B2B2B" />
        <SolidColorBrush x:Key="Ink"        Color="#FAFAFA" />
        <SolidColorBrush x:Key="Muted"      Color="#A1A1AA" />
        <SolidColorBrush x:Key="Dim"        Color="#71717A" />
        <SolidColorBrush x:Key="Accent"     Color="#E7000B" />

        <!-- ince scrollbar; varsayilan WPF cubugu bu palette yabanci duruyor -->
        <Style x:Key="ScrollThumb" TargetType="Thumb">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Thumb">
                        <Border x:Name="t" Background="#2E2E2E" CornerRadius="3" Margin="2,0"/>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="t" Property="Background" Value="#4A4A4A"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style TargetType="ScrollBar">
            <Setter Property="Width" Value="10"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ScrollBar">
                        <Track x:Name="PART_Track" IsDirectionReversed="True">
                            <Track.Thumb><Thumb Style="{StaticResource ScrollThumb}"/></Track.Thumb>
                            <Track.IncreaseRepeatButton>
                                <RepeatButton Command="ScrollBar.PageDownCommand" Opacity="0" Focusable="False"/>
                            </Track.IncreaseRepeatButton>
                            <Track.DecreaseRepeatButton>
                                <RepeatButton Command="ScrollBar.PageUpCommand" Opacity="0" Focusable="False"/>
                            </Track.DecreaseRepeatButton>
                        </Track>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- segment dugmesi: zemini kayan hap ciziyor, dugme sadece yaziyi tasiyor -->
        <Style x:Key="SegBtn" TargetType="RadioButton">
            <Setter Property="Foreground" Value="{StaticResource Dim}"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="RadioButton">
                        <Border Background="#00FFFFFF" Cursor="Hand">
                            <ContentPresenter VerticalAlignment="Center" HorizontalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Foreground" Value="{StaticResource Muted}"/>
                            </Trigger>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter Property="Foreground" Value="{StaticResource Ink}"/>
                                <Setter Property="FontWeight" Value="SemiBold"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- kenar cubugu ogesi: seciliyken solda kirmizi ince cizgi -->
        <Style x:Key="NavBtn" TargetType="RadioButton">
            <Setter Property="Foreground" Value="{StaticResource Dim}"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="RadioButton">
                        <Border x:Name="bd" CornerRadius="7" Margin="12,1" Padding="14,9" Cursor="Hand">
                            <Border.Background><SolidColorBrush Color="#00FFFFFF"/></Border.Background>
                            <Grid>
                                <Border x:Name="bar" Width="2" Height="6" CornerRadius="1" Opacity="0"
                                        Background="{StaticResource Accent}" HorizontalAlignment="Left"/>
                                <ContentPresenter Margin="14,0,0,0" VerticalAlignment="Center"/>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Foreground" Value="{StaticResource Muted}"/>
                                <Trigger.EnterActions>
                                    <BeginStoryboard><Storyboard>
                                        <ColorAnimation Storyboard.TargetName="bd" Storyboard.TargetProperty="Background.Color"
                                                        To="#14FFFFFF" Duration="0:0:0.15"/>
                                    </Storyboard></BeginStoryboard>
                                </Trigger.EnterActions>
                                <Trigger.ExitActions>
                                    <BeginStoryboard><Storyboard>
                                        <ColorAnimation Storyboard.TargetName="bd" Storyboard.TargetProperty="Background.Color"
                                                        To="#00FFFFFF" Duration="0:0:0.2"/>
                                    </Storyboard></BeginStoryboard>
                                </Trigger.ExitActions>
                            </Trigger>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter Property="Foreground" Value="{StaticResource Ink}"/>
                                <Setter Property="FontWeight" Value="SemiBold"/>
                                <Trigger.EnterActions>
                                    <BeginStoryboard><Storyboard>
                                        <DoubleAnimation Storyboard.TargetName="bar" Storyboard.TargetProperty="Opacity"
                                                         To="1" Duration="0:0:0.18"/>
                                        <DoubleAnimation Storyboard.TargetName="bar" Storyboard.TargetProperty="Height"
                                                         To="16" Duration="0:0:0.28">
                                            <DoubleAnimation.EasingFunction><CubicEase EasingMode="EaseOut"/></DoubleAnimation.EasingFunction>
                                        </DoubleAnimation>
                                    </Storyboard></BeginStoryboard>
                                </Trigger.EnterActions>
                                <Trigger.ExitActions>
                                    <BeginStoryboard><Storyboard>
                                        <DoubleAnimation Storyboard.TargetName="bar" Storyboard.TargetProperty="Opacity"
                                                         To="0" Duration="0:0:0.15"/>
                                        <DoubleAnimation Storyboard.TargetName="bar" Storyboard.TargetProperty="Height"
                                                         To="6" Duration="0:0:0.15"/>
                                    </Storyboard></BeginStoryboard>
                                </Trigger.ExitActions>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="PrimaryBtn" TargetType="Button">
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bd" CornerRadius="7">
                            <Border.Background><SolidColorBrush Color="#E7000B"/></Border.Background>
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="18,10"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Trigger.EnterActions>
                                    <BeginStoryboard><Storyboard>
                                        <ColorAnimation Storyboard.TargetName="bd" Storyboard.TargetProperty="Background.Color"
                                                        To="#FB2C36" Duration="0:0:0.15"/>
                                    </Storyboard></BeginStoryboard>
                                </Trigger.EnterActions>
                                <Trigger.ExitActions>
                                    <BeginStoryboard><Storyboard>
                                        <ColorAnimation Storyboard.TargetName="bd" Storyboard.TargetProperty="Background.Color"
                                                        To="#E7000B" Duration="0:0:0.2"/>
                                    </Storyboard></BeginStoryboard>
                                </Trigger.ExitActions>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="bd" Property="Opacity" Value="0.35"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="GhostBtn" TargetType="Button">
            <Setter Property="Foreground" Value="{StaticResource Muted}"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bd" CornerRadius="7" BorderBrush="{StaticResource RuleStrong}" BorderThickness="1">
                            <Border.Background><SolidColorBrush Color="#00FFFFFF"/></Border.Background>
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="16,9"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Foreground" Value="{StaticResource Ink}"/>
                                <Trigger.EnterActions>
                                    <BeginStoryboard><Storyboard>
                                        <ColorAnimation Storyboard.TargetName="bd" Storyboard.TargetProperty="Background.Color"
                                                        To="#1FFFFFFF" Duration="0:0:0.15"/>
                                    </Storyboard></BeginStoryboard>
                                </Trigger.EnterActions>
                                <Trigger.ExitActions>
                                    <BeginStoryboard><Storyboard>
                                        <ColorAnimation Storyboard.TargetName="bd" Storyboard.TargetProperty="Background.Color"
                                                        To="#00FFFFFF" Duration="0:0:0.2"/>
                                    </Storyboard></BeginStoryboard>
                                </Trigger.ExitActions>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Foreground" Value="{StaticResource Dim}"/>
                                <Setter TargetName="bd" Property="Opacity" Value="0.4"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="WinBtn" TargetType="Button">
            <Setter Property="Width" Value="46"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bd" Background="#00FFFFFF">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="bd" Property="Background" Value="#1FFFFFFF"/>
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
                        <Border x:Name="bd" Background="#00FFFFFF">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="bd" Property="Background" Value="#E7000B"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style x:Key="WinIcon" TargetType="Path">
            <Setter Property="Stroke" Value="#A1A1AA"/>
            <Setter Property="StrokeThickness" Value="1.2"/>
            <Setter Property="SnapsToDevicePixels" Value="True"/>
        </Style>
    </Window.Resources>

    <Border Background="{StaticResource Paper}" CornerRadius="10" ClipToBounds="True"
            BorderBrush="{StaticResource RuleStrong}" BorderThickness="1">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="48"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="256"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <!-- ============================ baslik cubugu ============================ -->
            <Border Grid.Row="0" Grid.ColumnSpan="2" Background="{StaticResource Paper}" x:Name="TitleBar">
                <Grid>
                    <StackPanel Orientation="Horizontal" Margin="18,0,0,0" VerticalAlignment="Center">
                        <Border Width="22" Height="22" CornerRadius="6" Background="{StaticResource Accent}">
                            <TextBlock Text="T" Foreground="#FFFFFF" FontSize="13" FontWeight="Bold"
                                       HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <TextBlock Text="TRSS Tools" Foreground="{StaticResource Ink}" FontWeight="SemiBold"
                                   FontSize="13.5" VerticalAlignment="Center" Margin="11,0,0,0"/>
                        <Border CornerRadius="10" Height="20" Background="{StaticResource Surface}" Padding="8,0"
                                Margin="10,1,0,0" VerticalAlignment="Center">
                            <TextBlock x:Name="SurumEtiket" Text="v3.0" Foreground="{StaticResource Dim}"
                                       FontSize="10" VerticalAlignment="Center"/>
                        </Border>
                        <Border x:Name="YetkiRozet" CornerRadius="10" Height="20" Background="{StaticResource Surface}"
                                Padding="8,0" Margin="7,1,0,0" VerticalAlignment="Center">
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <Border x:Name="YetkiNokta" Width="5" Height="5" CornerRadius="3"
                                        Background="{StaticResource Accent}" VerticalAlignment="Center"/>
                                <TextBlock x:Name="YetkiYazi" Text="Sınırlı" Foreground="{StaticResource Dim}"
                                           FontSize="10" Margin="6,0,0,0" VerticalAlignment="Center"/>
                            </StackPanel>
                        </Border>
                    </StackPanel>

                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                        <Button x:Name="BtnKucult" Style="{StaticResource WinBtn}">
                            <Path Style="{StaticResource WinIcon}" Data="M0,0 L10,0"/>
                        </Button>
                        <Button x:Name="BtnBuyut" Style="{StaticResource WinBtn}">
                            <Path Style="{StaticResource WinIcon}" Data="M0.5,0.5 L9.5,0.5 L9.5,9.5 L0.5,9.5 Z"/>
                        </Button>
                        <Button x:Name="BtnKapat" Style="{StaticResource WinCloseBtn}">
                            <Path Style="{StaticResource WinIcon}" Data="M0,0 L9,9 M9,0 L0,9"/>
                        </Button>
                    </StackPanel>
                    <Border VerticalAlignment="Bottom" Height="1" Background="{StaticResource Rule}"/>
                </Grid>
            </Border>

            <!-- ============================= kenar cubugu ============================ -->
            <Border Grid.Row="1" Grid.Column="0" Background="{StaticResource Paper}">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <Border x:Name="SegHost" Height="40" CornerRadius="20" Margin="18,18,18,0"
                            Background="{StaticResource Elevated}" BorderBrush="{StaticResource Rule}" BorderThickness="1">
                        <Grid>
                            <Border x:Name="SegHap" Width="100" Margin="4" CornerRadius="16"
                                    HorizontalAlignment="Left" Background="#262626">
                                <Border.RenderTransform><TranslateTransform x:Name="SegKaydir" X="0"/></Border.RenderTransform>
                            </Border>
                            <UniformGrid Rows="1">
                                <RadioButton x:Name="SekmeAraclar" Content="Araçlar" Style="{StaticResource SegBtn}"
                                             GroupName="AnaSekme" IsChecked="True"/>
                                <RadioButton x:Name="SekmeScriptler" Content="Scriptler" Style="{StaticResource SegBtn}"
                                             GroupName="AnaSekme"/>
                            </UniformGrid>
                        </Grid>
                    </Border>

                    <TextBlock x:Name="NavBaslik" Grid.Row="1" Text="KATEGORİLER" Foreground="{StaticResource Dim}"
                               FontSize="10" FontWeight="SemiBold" Margin="26,22,0,10"/>

                    <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto" Padding="0,0,4,10">
                        <StackPanel x:Name="KategoriListesi"/>
                    </ScrollViewer>

                    <!-- imza -->
                    <StackPanel Grid.Row="3" Margin="26,14,18,20">
                        <Border Height="1" Background="{StaticResource Rule}" Margin="0,0,0,14"/>
                        <Image x:Name="Imza" Height="26" HorizontalAlignment="Left" Stretch="Uniform"
                               Opacity="0.55" Visibility="Collapsed" SnapsToDevicePixels="True"/>
                        <TextBlock x:Name="ImzaYazi" Text="boboalover" Foreground="{StaticResource Dim}"
                                   FontSize="11" Margin="0,8,0,0"/>
                    </StackPanel>

                    <Border Grid.RowSpan="4" HorizontalAlignment="Right" Width="1" Background="{StaticResource Rule}"/>
                </Grid>
            </Border>

            <!-- ================================ icerik =============================== -->
            <ScrollViewer x:Name="AnaKaydirici" Grid.Row="1" Grid.Column="1" VerticalScrollBarVisibility="Auto"
                          HorizontalScrollBarVisibility="Disabled" Padding="30,24,18,28">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <Grid Margin="2,0,10,18">
                        <StackPanel HorizontalAlignment="Left" VerticalAlignment="Center">
                            <TextBlock x:Name="Baslik" Text="Genel Bakış" FontSize="26" FontWeight="Bold"
                                       Foreground="{StaticResource Ink}"/>
                            <TextBlock x:Name="Aciklama" Text="Yükleniyor..." FontSize="13"
                                       Foreground="{StaticResource Dim}" Margin="0,7,0,0"/>
                        </StackPanel>
                        <Button x:Name="BtnKategoriIndir" Content="Kategoriyi İndir" Style="{StaticResource PrimaryBtn}"
                                HorizontalAlignment="Right" VerticalAlignment="Center" Visibility="Collapsed"/>
                    </Grid>

                    <Border Grid.Row="1" Height="1" Background="{StaticResource Rule}" Margin="2,0,10,20"/>

                    <WrapPanel x:Name="KartAlani" Grid.Row="2" ItemWidth="424" Margin="-6,0,0,0"/>
                </Grid>
            </ScrollViewer>

            <!-- ============================== alt konsol ============================= -->
            <Border Grid.Row="2" Grid.ColumnSpan="2" Background="{StaticResource Paper}"
                    BorderBrush="{StaticResource Rule}" BorderThickness="0,1,0,0">
                <Grid Margin="26,18,26,20">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="30"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>

                    <StackPanel Grid.Column="0" VerticalAlignment="Center">
                        <Grid Margin="0,0,0,9">
                            <TextBlock x:Name="DurumYazi" Text="Hazır." Foreground="{StaticResource Muted}" FontSize="12"/>
                            <TextBlock x:Name="YuzdeYazi" Text="" Foreground="{StaticResource Dim}" FontSize="12"
                                       HorizontalAlignment="Right"/>
                        </Grid>
                        <Border x:Name="IlerlemeYolu" Height="4" Background="{StaticResource Surface}"
                                CornerRadius="2" ClipToBounds="True">
                            <Border x:Name="IlerlemeCubugu" HorizontalAlignment="Left" Width="0"
                                    Background="{StaticResource Accent}" CornerRadius="2"/>
                        </Border>
                        <Border Margin="0,12,0,0" CornerRadius="7" Background="{StaticResource Elevated}"
                                BorderBrush="{StaticResource Rule}" BorderThickness="1" Padding="12,8">
                            <TextBox x:Name="Gunluk" Height="58" Background="#00FFFFFF" BorderThickness="0" Padding="0"
                                     Foreground="{StaticResource Dim}" FontFamily="Consolas" FontSize="11.5"
                                     IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="NoWrap"
                                     SelectionBrush="{StaticResource Accent}"/>
                        </Border>
                    </StackPanel>

                    <StackPanel Grid.Column="2" VerticalAlignment="Center">
                        <Button x:Name="BtnHepsiniIndir" Content="HEPSİNİ İNDİR" Style="{StaticResource PrimaryBtn}"
                                Margin="0,0,10,10" Height="46" Width="250" FontSize="13"/>
                        <Grid Margin="0,0,10,0">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="10"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <Button x:Name="BtnKlasorAc" Grid.Column="0" Content="Klasörü Aç" Style="{StaticResource GhostBtn}"/>
                            <Button x:Name="BtnYenile" Grid.Column="2" Content="Yenile" Style="{StaticResource GhostBtn}"/>
                        </Grid>
                    </StackPanel>
                </Grid>
            </Border>
        </Grid>
    </Border>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# --------------------------------------------------------------- referanslar -

$UI = @{}
foreach ($ad in @("TitleBar","BtnKucult","BtnBuyut","BtnKapat","SurumEtiket","YetkiRozet","YetkiNokta","YetkiYazi",
                  "SegHost","SegHap","SegKaydir","SekmeAraclar","SekmeScriptler","NavBaslik","KategoriListesi",
                  "Imza","ImzaYazi","AnaKaydirici","Baslik","Aciklama","BtnKategoriIndir","KartAlani",
                  "DurumYazi","YuzdeYazi","IlerlemeYolu","IlerlemeCubugu","Gunluk",
                  "BtnHepsiniIndir","BtnKlasorAc","BtnYenile")) {
    $UI[$ad] = $window.FindName($ad)
}
$global:UI = $UI

# ------------------------------------------------------------- yardimcilar ---

function Yaz-Gunluk {
    param([string]$mesaj)
    $zaman = Get-Date -Format "HH:mm:ss"
    $global:UI.Gunluk.AppendText("[$zaman] $mesaj`n")
    $global:UI.Gunluk.ScrollToEnd()
    [System.Windows.Forms.Application]::DoEvents()
}

function Set-Ilerleme {
    param([double]$oran)
    $genislik = $global:UI.IlerlemeYolu.ActualWidth
    $global:UI.IlerlemeCubugu.Width = [Math]::Max(0, [Math]::Min($genislik, $genislik * $oran))
    $global:UI.YuzdeYazi.Text = if ($oran -gt 0) { "%" + [Math]::Round($oran * 100) } else { "" }
}

# giris animasyonu: hafif yukselerek belirme, karta gore gecikmeli
function Anim-Giris {
    param($oge, [int]$sira = 0)
    $oge.Opacity = 0
    $tt = New-Object System.Windows.Media.TranslateTransform
    $oge.RenderTransform = $tt

    $sure = [Windows.Duration]::new([TimeSpan]::FromMilliseconds(300))
    $yumusak = New-Object System.Windows.Media.Animation.CubicEase
    $yumusak.EasingMode = 'EaseOut'
    $gecikme = [TimeSpan]::FromMilliseconds([Math]::Min(24 * $sira, 400))

    $solma = New-Object System.Windows.Media.Animation.DoubleAnimation(0, 1, $sure)
    $solma.BeginTime = $gecikme
    $solma.EasingFunction = $yumusak

    $kayma = New-Object System.Windows.Media.Animation.DoubleAnimation(14, 0, $sure)
    $kayma.BeginTime = $gecikme
    $kayma.EasingFunction = $yumusak

    $oge.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $solma)
    $tt.BeginAnimation([System.Windows.Media.TranslateTransform]::YProperty, $kayma)
}

function Anim-Kaydir {
    param($donusum, [double]$hedef)
    $an = New-Object System.Windows.Media.Animation.DoubleAnimation($hedef, [Windows.Duration]::new([TimeSpan]::FromMilliseconds(280)))
    $yumusak = New-Object System.Windows.Media.Animation.CubicEase
    $yumusak.EasingMode = 'EaseOut'
    $an.EasingFunction = $yumusak
    $donusum.BeginAnimation([System.Windows.Media.TranslateTransform]::XProperty, $an)
}

function Test-AracKurulu {
    param($arac)
    $klasor = Join-Path $global:ToolsRoot $arac.klasor
    if ($arac.tip -eq "zip") {
        if (Test-Path (Join-Path $klasor ($arac.ad -replace "\.zip$",""))) { return $true }
    }
    return (Test-Path (Join-Path $klasor $arac.ad))
}

function Expand-ZipGuvenli {
    param($zip, $hedef)
    try {
        if (Test-Path $hedef) { Remove-Item $hedef -Recurse -Force -ErrorAction SilentlyContinue }
        Expand-Archive $zip $hedef -Force
        return $true
    } catch {
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $hedef)
            return $true
        } catch { return $false }
    }
}

function Format-Boyut {
    param([long]$bayt)
    if ($bayt -ge 1MB) { return "{0:N1} MB" -f ($bayt / 1MB) }
    if ($bayt -ge 1KB) { return "{0:N0} KB" -f ($bayt / 1KB) }
    return "$bayt B"
}

# Parcali indirme: her blok sonrasi arayuz nefes alir, animasyonlar akmaya devam eder.
function Invoke-Indirme {
    param($adres, $hedef, [scriptblock]$ilerleyince)
    $istek = [System.Net.HttpWebRequest]::Create($adres)
    $istek.UserAgent = "Mozilla/5.0 (TRSS-Tools)"
    $istek.Timeout = 30000
    $istek.ReadWriteTimeout = 60000
    $yanit = $istek.GetResponse()
    $toplam = $yanit.ContentLength
    $giris = $yanit.GetResponseStream()
    $cikis = [System.IO.File]::Create($hedef)
    try {
        $tampon = New-Object byte[] 65536
        $inen = 0L
        while (($okunan = $giris.Read($tampon, 0, $tampon.Length)) -gt 0) {
            $cikis.Write($tampon, 0, $okunan)
            $inen += $okunan
            $oran = if ($toplam -gt 0) { $inen / $toplam } else { -1 }
            & $ilerleyince $oran $inen $toplam
            [System.Windows.Forms.Application]::DoEvents()
        }
    } finally {
        $cikis.Close(); $giris.Close(); $yanit.Close()
    }
}

function Set-EylemDurumu {
    param([bool]$acik)
    $global:UI.BtnHepsiniIndir.IsEnabled = $acik
    $global:UI.BtnKategoriIndir.IsEnabled = $acik
    $global:UI.BtnYenile.IsEnabled = $acik
}

function Start-Indirme {
    param($araclar)
    if ($global:Mesgul) { return }
    if (-not $araclar -or $araclar.Count -eq 0) { return }

    $global:Mesgul = $true
    Set-EylemDurumu $false
    $adet = $araclar.Count
    $basarili = 0; $atlanan = 0; $hatali = 0

    for ($i = 0; $i -lt $adet; $i++) {
        $arac = $araclar[$i]
        $klasor = Join-Path $global:ToolsRoot $arac.klasor
        $hedef = Join-Path $klasor $arac.ad
        if (-not (Test-Path $klasor)) { New-Item -ItemType Directory $klasor -Force | Out-Null }

        $kart = $global:KartRef[$arac.ad]

        if (Test-AracKurulu $arac) {
            Yaz-Gunluk "Zaten kurulu: $($arac.ad)"
            $atlanan++
            Set-Ilerleme (($i + 1) / $adet)
            continue
        }

        $global:UI.DurumYazi.Text = "İndiriliyor ($($i+1)/$adet): $($arac.ad)"
        Yaz-Gunluk "İndiriliyor: $($arac.ad)"
        if ($kart) {
            $kart.DugmeYazi.Text = "İndiriliyor"
            $kart.Iz.Visibility = 'Visible'
        }

        try {
            Invoke-Indirme $arac.url $hedef {
                param($oran, $inen, $toplam)
                if ($kart -and $oran -ge 0) {
                    $kart.Cubuk.Width = [Math]::Max(0, $kart.Iz.ActualWidth * $oran)
                    $kart.DugmeYazi.Text = "%" + [Math]::Round($oran * 100)
                }
                $tamamlanan = if ($oran -ge 0) { ($i + $oran) / $adet } else { ($i + 0.5) / $adet }
                Set-Ilerleme $tamamlanan
            }

            if ($arac.tip -eq "zip") {
                if ($kart) { $kart.DugmeYazi.Text = "Ayıklanıyor" }
                $cikartilan = Join-Path $klasor ($arac.ad -replace "\.zip$","")
                if (Expand-ZipGuvenli $hedef $cikartilan) {
                    Remove-Item $hedef -Force -ErrorAction SilentlyContinue
                    Yaz-Gunluk "   ayıklandı -> $($arac.klasor)"
                } else {
                    Yaz-Gunluk "   ayıklama hatası: $($arac.ad)"
                }
            }
            $basarili++
            Yaz-Gunluk "   tamamlandı"
        } catch {
            $hatali++
            Yaz-Gunluk "   HATA: $($arac.ad) - $($_.Exception.Message)"
            if (Test-Path $hedef) { Remove-Item $hedef -Force -ErrorAction SilentlyContinue }
        }

        Set-Ilerleme (($i + 1) / $adet)
    }

    $global:UI.DurumYazi.Text = "Bitti  ·  $basarili indirildi, $atlanan zaten kurulu, $hatali hata"
    $global:Mesgul = $false
    Set-EylemDurumu $true
}

# ------------------------------------------------------------------ kartlar --

# Kart govdesi: hairline cerceve, 150 ms hover gecisi.
# Her kart ayri bir XAML parcasi olarak ayristirilir, isim kapsami kendine ait.
function Get-KartGovde {
    param($yukseklik, $imlec = "Arrow")
    return @"
        <Border BorderThickness="1" CornerRadius="7" Margin="6" Height="$yukseklik" Cursor="$imlec"
                xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
            <Border.Background><SolidColorBrush Color="#121212"/></Border.Background>
            <Border.BorderBrush><SolidColorBrush Color="#1F1F1F"/></Border.BorderBrush>
            <Border.Style>
                <Style TargetType="Border">
                    <Style.Triggers>
                        <Trigger Property="IsMouseOver" Value="True">
                            <Trigger.EnterActions>
                                <BeginStoryboard><Storyboard>
                                    <ColorAnimation Storyboard.TargetProperty="Background.Color" To="#1A1A1A" Duration="0:0:0.15"/>
                                    <ColorAnimation Storyboard.TargetProperty="BorderBrush.Color" To="#2E2E2E" Duration="0:0:0.15"/>
                                </Storyboard></BeginStoryboard>
                            </Trigger.EnterActions>
                            <Trigger.ExitActions>
                                <BeginStoryboard><Storyboard>
                                    <ColorAnimation Storyboard.TargetProperty="Background.Color" To="#121212" Duration="0:0:0.25"/>
                                    <ColorAnimation Storyboard.TargetProperty="BorderBrush.Color" To="#1F1F1F" Duration="0:0:0.25"/>
                                </Storyboard></BeginStoryboard>
                            </Trigger.ExitActions>
                        </Trigger>
                    </Style.Triggers>
                </Style>
            </Border.Style>
"@
}

# Kart ici eylem dugmesi. Kirmizi yalnizca birincil eylemlerde kullanilir,
# kart icindekiler hairline kalir ki tek marka rengi kalabalikta anlamini yitirmesin.
function Get-KartDugme {
    param($yazi, $tur, $sutun, $genislik = 96)
    if     ($tur -eq "accent") { $zemin="#E7000B"; $hover="#FB2C36"; $renk="#FFFFFF"; $cerceve="#00000000" }
    elseif ($tur -eq "strong") { $zemin="#00FFFFFF"; $hover="#24FFFFFF"; $renk="#FAFAFA"; $cerceve="#3A3A3A" }
    else                       { $zemin="#00FFFFFF"; $hover="#1AFFFFFF"; $renk="#A1A1AA"; $cerceve="#2B2B2B" }
    return @"
            <Border x:Name="Dugme" Grid.Column="$sutun" BorderBrush="$cerceve" BorderThickness="1" CornerRadius="7"
                    Width="$genislik" VerticalAlignment="Center" HorizontalAlignment="Right" Cursor="Hand">
                <Border.Background><SolidColorBrush Color="$zemin"/></Border.Background>
                <Border.Style>
                    <Style TargetType="Border">
                        <Style.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Trigger.EnterActions>
                                    <BeginStoryboard><Storyboard>
                                        <ColorAnimation Storyboard.TargetProperty="Background.Color" To="$hover" Duration="0:0:0.15"/>
                                    </Storyboard></BeginStoryboard>
                                </Trigger.EnterActions>
                                <Trigger.ExitActions>
                                    <BeginStoryboard><Storyboard>
                                        <ColorAnimation Storyboard.TargetProperty="Background.Color" To="$zemin" Duration="0:0:0.25"/>
                                    </Storyboard></BeginStoryboard>
                                </Trigger.ExitActions>
                            </Trigger>
                        </Style.Triggers>
                    </Style>
                </Border.Style>
                <TextBlock x:Name="DugmeYazi" Text="$yazi" Foreground="$renk" FontSize="12" FontWeight="SemiBold"
                           HorizontalAlignment="Center" Margin="0,10,0,10"/>
            </Border>
"@
}

function Show-GenelBakis {
    $global:UI.Baslik.Text = "Genel Bakış"
    $global:UI.BtnKategoriIndir.Visibility = 'Collapsed'
    $global:UI.KartAlani.Children.Clear()
    $global:KartRef.Clear()
    $global:SonKat = ""
    $global:UI.AnaKaydirici.ScrollToTop()

    if ($global:AracListesi.Count -eq 0) {
        $global:UI.Aciklama.Text = "Katalog yüklenemedi. İnternet bağlantını kontrol edip Yenile'ye bas."
        return
    }

    $toplam = $global:AracListesi.Count
    $kurulu = @($global:AracListesi | Where-Object { Test-AracKurulu $_ }).Count
    $global:UI.Aciklama.Text = "$kurulu / $toplam araç hazır  ·  bir kategori seç veya hepsini indir"

    $sira = 0
    foreach ($kat in ($global:AracListesi | Select-Object -ExpandProperty klasor -Unique)) {
        $katAraclar = @($global:AracListesi | Where-Object { $_.klasor -eq $kat })
        $adet = $katAraclar.Count
        $hazir = @($katAraclar | Where-Object { Test-AracKurulu $_ }).Count
        $dolu = [Math]::Max(0.0001, $hazir)
        $bos  = [Math]::Max(0.0001, $adet - $hazir)
        $cubukRenk = if ($hazir -eq $adet) { "#FAFAFA" } else { "#E7000B" }

        $kod = (Get-KartGovde 106 "Hand") + @"
            <Grid Margin="20,0,20,0">
                <StackPanel VerticalAlignment="Center">
                    <Grid>
                        <TextBlock Text="$kat" Foreground="#FAFAFA" FontSize="15" FontWeight="SemiBold" VerticalAlignment="Center"/>
                        <TextBlock Text="$hazir/$adet" Foreground="#71717A" FontSize="12"
                                   HorizontalAlignment="Right" VerticalAlignment="Center"/>
                    </Grid>
                    <Border Height="3" Background="#1F1F1F" CornerRadius="2" Margin="0,14,0,0" ClipToBounds="True">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="$dolu*"/>
                                <ColumnDefinition Width="$bos*"/>
                            </Grid.ColumnDefinitions>
                            <Border Grid.Column="0" Background="$cubukRenk" CornerRadius="2"/>
                        </Grid>
                    </Border>
                    <TextBlock Text="$hazir araç kurulu, $($adet - $hazir) eksik" Foreground="#71717A" FontSize="11" Margin="0,10,0,0"/>
                </StackPanel>
            </Grid>
        </Border>
"@
        $kart = [Windows.Markup.XamlReader]::Parse($kod)
        $kart.Tag = $kat
        $kart.Add_MouseLeftButtonUp({ param($gonderen, $olay)
            if (-not $global:Mesgul) { Show-Kategori $gonderen.Tag }
        })
        Anim-Giris $kart $sira
        [void]$global:UI.KartAlani.Children.Add($kart)
        $sira++
    }
}

function Show-Kategori {
    param($kat)
    $global:UI.Baslik.Text = $kat
    $katAraclar = @($global:AracListesi | Where-Object { $_.klasor -eq $kat })
    $hazir = @($katAraclar | Where-Object { Test-AracKurulu $_ }).Count
    $global:UI.Aciklama.Text = "$($katAraclar.Count) araç  ·  $hazir kurulu, $($katAraclar.Count - $hazir) eksik"

    $global:UI.BtnKategoriIndir.Visibility = 'Visible'
    $global:UI.BtnKategoriIndir.Tag = $katAraclar
    $global:UI.KartAlani.Children.Clear()
    $global:KartRef.Clear()

    # indirme sonrasi tazelemede konumu koru, sadece kategori degisince basa don
    $animasyonlu = ($global:SonKat -ne $kat)
    if ($animasyonlu) { $global:UI.AnaKaydirici.ScrollToTop() }
    $global:SonKat = $kat

    foreach ($nav in $global:UI.KategoriListesi.Children) {
        if ($nav.Tag -eq $kat) { $nav.IsChecked = $true }
    }

    $sira = 0
    foreach ($arac in $katAraclar) {
        $kurulu = Test-AracKurulu $arac
        $durumRenk = if ($kurulu) { "#A1A1AA" } else { "#E7000B" }
        $durumYazi = if ($kurulu) { "Kurulu" } else { "Eksik" }
        $dugmeTur  = if ($kurulu) { "ghost" } else { "strong" }
        $dugmeYazi = if ($kurulu) { "Yenile" } else { "İndir" }

        $kod = (Get-KartGovde 116) + @"
            <Grid Margin="20,0,18,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="108"/>
                </Grid.ColumnDefinitions>

                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,14,0">
                    <StackPanel Orientation="Horizontal">
                        <Border Background="#1F1F1F" CornerRadius="4" Padding="6,2" Margin="0,1,9,0" VerticalAlignment="Center">
                            <TextBlock Text="$($arac.tip.ToUpper())" Foreground="#71717A" FontSize="9" FontWeight="Bold"/>
                        </Border>
                        <TextBlock Text="$($arac.ad)" Foreground="#FAFAFA" FontSize="14" FontWeight="SemiBold"
                                   VerticalAlignment="Center" TextTrimming="CharacterEllipsis"/>
                    </StackPanel>
                    <TextBlock Text="$($arac.aciklama)" Foreground="#71717A" FontSize="12" Margin="0,8,0,0" TextWrapping="Wrap"/>
                    <StackPanel Orientation="Horizontal" Margin="0,10,0,0">
                        <Border Width="5" Height="5" CornerRadius="3" Background="$durumRenk" VerticalAlignment="Center"/>
                        <TextBlock Text="$durumYazi" Foreground="$durumRenk" FontSize="11" Margin="7,0,0,0" VerticalAlignment="Center"/>
                    </StackPanel>
                </StackPanel>
"@ + (Get-KartDugme $dugmeYazi $dugmeTur 1 100) + @"
                <Border x:Name="Iz" Grid.ColumnSpan="2" Height="2" Background="#1F1F1F" VerticalAlignment="Bottom"
                        Margin="-20,0,-18,0" Visibility="Collapsed" ClipToBounds="True">
                    <Border x:Name="Cubuk" HorizontalAlignment="Left" Width="0" Background="#E7000B"/>
                </Border>
            </Grid>
        </Border>
"@
        $kart = [Windows.Markup.XamlReader]::Parse($kod)
        $dugme = $kart.FindName("Dugme")
        $dugme.Tag = $arac
        $dugme.Add_MouseLeftButtonUp({ param($gonderen, $olay)
            if ($global:Mesgul) { return }
            Start-Indirme @($gonderen.Tag)
            Show-Kategori $global:UI.Baslik.Text
        })

        $global:KartRef[$arac.ad] = @{
            Kart      = $kart
            Dugme     = $dugme
            DugmeYazi = $kart.FindName("DugmeYazi")
            Iz        = $kart.FindName("Iz")
            Cubuk     = $kart.FindName("Cubuk")
        }

        if ($animasyonlu) { Anim-Giris $kart $sira }
        [void]$global:UI.KartAlani.Children.Add($kart)
        $sira++
    }
}

function Show-Scriptler {
    $global:UI.Baslik.Text = "Scriptler"
    $global:UI.Aciklama.Text = "Harici PowerShell scriptlerini doğrudan çalıştır  ·  $($global:ScriptListesi.Count) script"
    $global:UI.BtnKategoriIndir.Visibility = 'Collapsed'
    $global:UI.KartAlani.Children.Clear()
    $global:KartRef.Clear()
    $global:SonKat = ""
    $global:UI.AnaKaydirici.ScrollToTop()

    $sira = 0
    foreach ($ps in $global:ScriptListesi) {
        $kod = (Get-KartGovde 128) + @"
            <Grid Margin="20,0,18,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="108"/>
                </Grid.ColumnDefinitions>

                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,14,0">
                    <TextBlock Text="$($ps.ad)" Foreground="#FAFAFA" FontSize="15" FontWeight="SemiBold"/>
                    <StackPanel Orientation="Horizontal" Margin="0,7,0,9">
                        <Border Width="5" Height="5" CornerRadius="3" Background="#E7000B" VerticalAlignment="Center"/>
                        <TextBlock Text="$($ps.yazar)" Foreground="#A1A1AA" FontSize="11" Margin="7,0,0,0" VerticalAlignment="Center"/>
                    </StackPanel>
                    <TextBlock Text="$($ps.aciklama)" Foreground="#71717A" FontSize="12" TextWrapping="Wrap"/>
                </StackPanel>
"@ + (Get-KartDugme "Çalıştır" "strong" 1 100) + @"
            </Grid>
        </Border>
"@
        $kart = [Windows.Markup.XamlReader]::Parse($kod)
        $dugme = $kart.FindName("Dugme")
        $dugme.Tag = $ps.url
        $dugme.Add_MouseLeftButtonUp({ param($gonderen, $olay)
            $adres = $gonderen.Tag
            Yaz-Gunluk "Script başlatılıyor..."
            try {
                Start-Process powershell.exe -ArgumentList "-NoExit","-ExecutionPolicy","Bypass","-Command","iex (irm '$adres')"
                Yaz-Gunluk "   dış pencerede açıldı"
            } catch {
                Yaz-Gunluk "   script başlatılamadı"
            }
        })

        Anim-Giris $kart $sira
        [void]$global:UI.KartAlani.Children.Add($kart)
        $sira++
    }
}

function Build-KenarCubugu {
    $global:UI.KategoriListesi.Children.Clear()

    $genel = New-Object System.Windows.Controls.RadioButton
    $genel.Content = "Genel Bakış"
    $genel.Style = $window.Resources["NavBtn"]
    $genel.GroupName = "KatNav"
    $genel.IsChecked = $true
    $genel.Add_Click({ Show-GenelBakis })
    [void]$global:UI.KategoriListesi.Children.Add($genel)

    foreach ($kat in ($global:AracListesi | Select-Object -ExpandProperty klasor -Unique)) {
        $dugme = New-Object System.Windows.Controls.RadioButton
        $dugme.Content = $kat
        $dugme.Style = $window.Resources["NavBtn"]
        $dugme.GroupName = "KatNav"
        $dugme.Tag = $kat
        $dugme.Add_Click({ param($gonderen, $olay) Show-Kategori $gonderen.Tag })
        [void]$global:UI.KategoriListesi.Children.Add($dugme)
    }
}

# ------------------------------------------------------------------ olaylar --

$UI.TitleBar.Add_MouseLeftButtonDown({ $window.DragMove() })
$UI.BtnKapat.Add_Click({ $window.Close() })
$UI.BtnKucult.Add_Click({ $window.WindowState = 'Minimized' })
$UI.BtnBuyut.Add_Click({
    if ($window.WindowState -eq 'Maximized') { $window.WindowState = 'Normal' }
    else { $window.WindowState = 'Maximized' }
})

$UI.SekmeAraclar.Add_Click({
    if ($global:Mesgul) { return }
    Anim-Kaydir $global:UI.SegKaydir 0
    $global:UI.NavBaslik.Visibility = 'Visible'
    Build-KenarCubugu
    Show-GenelBakis
})
$UI.SekmeScriptler.Add_Click({
    if ($global:Mesgul) { return }
    Anim-Kaydir $global:UI.SegKaydir $global:UI.SegHap.Width
    $global:UI.KategoriListesi.Children.Clear()
    $global:UI.NavBaslik.Visibility = 'Collapsed'
    Show-Scriptler
})

$UI.BtnKategoriIndir.Add_Click({ param($gonderen, $olay)
    Yaz-Gunluk "Kategori indiriliyor: $($global:UI.Baslik.Text)"
    Start-Indirme $gonderen.Tag
    Show-Kategori $global:UI.Baslik.Text
})

$UI.BtnHepsiniIndir.Add_Click({
    Yaz-Gunluk "Tüm araçlar indiriliyor..."
    Start-Indirme $global:AracListesi
    if ($global:UI.Baslik.Text -eq "Genel Bakış") { Show-GenelBakis }
    elseif ($global:UI.Baslik.Text -eq "Scriptler") { Show-Scriptler }
    else { Show-Kategori $global:UI.Baslik.Text }
})

$UI.BtnKlasorAc.Add_Click({
    if (-not (Test-Path $global:ToolsRoot)) { New-Item -ItemType Directory $global:ToolsRoot -Force | Out-Null }
    Start-Process explorer.exe $global:ToolsRoot
})

$UI.BtnYenile.Add_Click({
    if ($global:Mesgul) { return }
    if ($global:UI.Baslik.Text -eq "Genel Bakış") { Show-GenelBakis }
    elseif ($global:UI.Baslik.Text -eq "Scriptler") { Show-Scriptler }
    else { $global:SonKat = ""; Show-Kategori $global:UI.Baslik.Text }
    Yaz-Gunluk "Durum güncellendi."
})

# ------------------------------------------------------------------- acilis --

$window.Add_Loaded({
    # segment hapinin genisligi konteynere gore hesaplanir, sabit sayi yok
    $yari = ($global:UI.SegHost.ActualWidth - 10) / 2
    $global:UI.SegHap.Width = $yari

    # pencere yumusak belirir
    $an = New-Object System.Windows.Media.Animation.DoubleAnimation(0, 1, [Windows.Duration]::new([TimeSpan]::FromMilliseconds(220)))
    $window.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $an)
})

$UI.SurumEtiket.Text = "v$global:Surum"

# yonetici rozeti
$yonetici = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if ($yonetici) {
    $UI.YetkiYazi.Text = "Yönetici"
    $UI.YetkiNokta.Background = New-Object System.Windows.Media.SolidColorBrush(
        [System.Windows.Media.Color]::FromRgb(161,161,170))
} else {
    $UI.YetkiYazi.Text = "Sınırlı yetki"
}

# imza: once depo kopyasi, sonra GitHub
try {
    $imzaBaytlar = $null
    $imzaYerel = if ($PSScriptRoot) { Join-Path $PSScriptRoot "signature.png" } else { $null }
    if ($imzaYerel -and (Test-Path $imzaYerel)) {
        $imzaBaytlar = [System.IO.File]::ReadAllBytes($imzaYerel)
    } else {
        $imzaBaytlar = (Invoke-WebRequest "$global:RepoRaw/signature.png" -UseBasicParsing -TimeoutSec 15).Content
    }
    if ($imzaBaytlar) {
        $bmp = New-Object System.Windows.Media.Imaging.BitmapImage
        $bmp.BeginInit()
        $bmp.StreamSource = New-Object System.IO.MemoryStream(,[byte[]]$imzaBaytlar)
        $bmp.CacheOption = 'OnLoad'
        $bmp.EndInit()
        $UI.Imza.Source = $bmp
        $UI.Imza.Visibility = 'Visible'
        $UI.ImzaYazi.Text = "boboalover  ·  katalog v$global:KatalogSurum"
    }
} catch {
    $UI.ImzaYazi.Text = "boboalover  ·  katalog v$global:KatalogSurum"
}

Build-KenarCubugu
Show-GenelBakis

Yaz-Gunluk "TRSS Tools v$global:Surum başlatıldı."
Yaz-Gunluk "Kurulum konumu: $global:ToolsRoot"
if ($global:AracListesi.Count -eq 0) {
    Yaz-Gunluk "Katalog alınamadı - internet bağlantısı yok veya GitHub erişilemiyor."
    $UI.DurumYazi.Text = "Katalog yüklenemedi."
} else {
    Yaz-Gunluk "Katalog v$global:KatalogSurum yüklendi - $($global:AracListesi.Count) araç, $($global:ScriptListesi.Count) script."
}

$window.ShowDialog() | Out-Null
