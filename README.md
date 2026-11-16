# ⚡ YuksekFPS — Windows Oyun & Gecikme Optimizasyon Aracı

**YuksekFPS**, Windows 10 ve Windows 11 sistemlerde rekabetçi oyunlar (CS2, Valorant vb.) için sistem gecikmesini (input lag) azaltmak, kare hızı tutarlılığını (%1 ve %0.1 Low FPS) artırmak ve gereksiz arka plan kaynak tüketimini ortadan kaldırmak amacıyla geliştirilmiş **%100 açık kaynaklı** bir PowerShell optimizasyon aracıdır.

---

## 🛡️ Güvenlik ve Şeffaflık Politikası

İnternet üzerinden tek satırlık komut (`irm ... | iex`) çalıştırmanın haklı olarak güvenlik endişeleri yarattığının farkındayız. Bu proje tamamen şeffaflık ilkesiyle hazırlanmıştır:

* **Kod Gizleme (Obfuscation) Yoktur:** Script içerisinde şifrelenmiş, Base64 ile gizlenmiş veya ne yaptığı belirsiz hiçbir satır bulunmaz. Tüm kaynak kodunu doğrudan [`yuksekfps.ps1`](./yuksekfps.ps1) dosyasından satır satır okuyabilirsiniz.
* **Veri Toplama Yoktur:** Script herhangi bir kişisel veriyi, donanım kimliğini veya kullanım istatistiğini hiçbir sunucuya göndermez.
* **Otomatik Geri Yükleme Noktası:** Herhangi bir sistem ayarı değiştirilmeden önce Windows **Sistem Geri Yükleme Noktası (System Restore Point)** otomatik olarak oluşturulur.
* **Kullanıcı Kontrolü:** Script, onayınız olmadan arka planda gizlice işlem yapmaz; uygulanacak adımları menü üzerinden seçmenize olanak tanır.

---

## 🚀 Hızlı Kurulum ve Kullanım

1. Başlat menüsüne **PowerShell** yazın, sağ tıklayın ve **Yönetici olarak çalıştır (Run as Administrator)** seçeneğine tıklayın.
2. Aşağıdaki komutu yapıştırıp **Enter** tuşuna basın:

```powershell
irm "[https://raw.githubusercontent.com/opcinn/yuksekfps/main/yuksekfps.ps1](https://raw.githubusercontent.com/opcinn/yuksekfps/main/yuksekfps.ps1)" | iex
