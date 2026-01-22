# Civilization Node 🌍
**Offline Survival Intelligence System & Air-Gapped AI Knowledge Base**

> **"Rebuild civilization without the internet."**

The **Civilization Node** is a self-contained, **offline AI system** designed for survivalists, preppers, and digital preservationists. It connects a powerful **Local LLM** (via **Ollama**) to a massive offline library of **Wikipedia, Engineering, Medicine, and Repair manuals** (via **Kiwix**).

Unlike standard chatbots, this system is **air-gapped capable** and designed to run on consumer hardware, providing critical knowledge retrieval when the internet is down.

**Key Features:**
*   **Offline Wikipedia & iFixit**: Access terabytes of knowledge without a connection.
*   **RAG (Retrieval Augmented Generation)**: The AI searches the offline library to answer questions accurately.
*   **Privacy First**: Runs entirely locally on your machine.
*   **Hardware Efficient**: Optimized for Linux/WSL2 with Docker.

**Keywords**: `Offline AI`, `Collapse OS`, `Prepper Tech`, `Kiwix Integration`, `Survival Intelligence`, `Local LLM`, `Ollama`, `Self-Hosted`, `Digital Heritage`.

---

## 💻 System Requirements / Sistem Gereksinimleri

### Operating System
- **Linux** (Recommended): Ubuntu 22.04 LTS or newer.
- **Windows**: Requires **WSL2** (Windows Subsystem for Linux) with Ubuntu installed.
- **Mac**: Supported (Intel/Apple Silicon), but requires manual adjustment of some Docker paths.

### Hardware Hardware
| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **RAM**   | 12 GB    | 16 GB+      |
| **GPU**   | CPU Only (Slow) | NVIDIA GPU (6GB VRAM+) |
| **Storage** | 100 GB | 1 TB SSD (For full library) |

> **Note on Storage**: The code itself is small, but the **offline content** (ZIM files) is massive.
> - `wikipedia_en_all_nopic`: ~50GB
> - `stackoverflow`: ~80GB
> - `ifixit`: ~2GB
> *Ensure you have enough space in `/opt/civilization` (or your chosen path).*

---

## 🛠️ Step 1: Install Prerequisites
Before you start, open a terminal (CTRL+ALT+T) and run these checks.

1. **Install Docker** (The engine that runs the web interface):
   ```bash
   # (If you don't have it)
   curl -fsSL https://get.docker.com | sh
   docker compose version  # Verify it installed
   ```
2. **Install Ollama** (The Brain):
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```
3. **Configure Ollama for External Access** (Critical!):
   By default, Ollama only listens to your computer. We need it to listen to the Docker container.
   ```bash
   sudo mkdir -p /etc/systemd/system/ollama.service.d
   echo '[Service]
   Environment="OLLAMA_HOST=0.0.0.0"' | sudo tee /etc/systemd/system/ollama.service.d/override.conf
   sudo systemctl daemon-reload
   sudo systemctl restart ollama
   ```

---

## 🧠 Step 2: Download the Brains (Models)
You need two types of brains: one for smarts, one for reading documents.

1. **Download the Unrestricted Model** (dolphin-llama3) - won't lecture you on safety:
   ```bash
   ollama pull dolphin-llama3
   # Create the Custom Survival Model (Applies the Librarian personality)
   ollama create survival-librarian -f Modelfile.survival
   ```
2. **Download the Librarian** (nomic-embed-text) - organizes your PDF manuals:
   ```bash
   ollama pull nomic-embed-text
   ```

---

## 📦 Step 3: Install the "Civilization Node"
Now, set up this repository.

1. **Configure Environment**:
   ```bash
   cp .env.example .env
   # (Optional) Edit .env if you want to store files on a specific hard drive
   # Default is /opt/civilization
   ```
2. **Create Directories**:
   ```bash
   ./setup_env.sh
   # Say 'y' if it asks for sudo permissions to create folders
   ```
3. **Start the Interface**:
   ```bash
   docker compose up -d
   ```

---

## 📚 Step 4: Download The Knowledge (Internet Archive)
You need the actual data (Wikipedia, iFixit, etc.). These files are big (100GB+).

1. **Run the Downloader**:
   ```bash
   ./maintenance/list_available_content.sh
   ```
   *Follow the on-screen menu to "browse" and "download" ZIM files.*
2. **Recommended Downloads**:
   - `wikipedia_en_all_nopic` (Encyclopedic knowledge)
   - `ifixit_en_all` (Repair guides)
   - `stackoverflow.com_en_all` (Coding/Engineering help)
   - `wikisource_en_medicine` (Medical texts)
   - `chemistry.stackexchange.com` (Chemical processes)

---

## 🚀 Step 5: Use It
1. **Open your Browser**: [http://localhost:3000](http://localhost:3000)
2. **Select Model**: Choose `survival-librarian` from the top dropdown.
3. **Connect the Tool** (Required for Wikipedia Access):
   - Go to **Workspace > Tools**.
   - Create a new tool named "Kiwix".
   - **Copy the content of `kiwix_tool.py`** from this repo and paste it there.
   - Click Save.
   - **Important**: When you start a New Chat, make sure to toggle the "Kiwix" tool provided in the chat options!

You are now ready. Access confirmed.

## ⚠️ Troubleshooting
- **AI "No results found"**: Ollama isn't running or isn't listening on 0.0.0.0. Re-run proper config in Step 1.
- **Library restarting**: A ZIM file might be corrupt. Check `/opt/civilization/library/zims`.

---

# 🇹🇷 Medeniyet Düğümü (Civilization Node)
**Çevrimdışı Hayatta Kalma ve İstihbarat Sistemi**

Bu sistem size **internet olmadan** çalışan tam otonom bir Yapay Zeka sunar. Güçlü bir LLM'i (beyin), Wikipedia, Mühendislik, Tıp ve Tamir kılavuzlarından oluşan devasa bir çevrimdışı kütüphaneye (bilgi) bağlar.

---

## 🛠️ Adım 1: Ön Hazırlıklar
Başlamadan önce bir terminal açın (CTRL+ALT+T) ve şu kontrolleri yapın.

1. **Docker Kurulumu** (Arayüzü çalıştıran motor):
   ```bash
   # (Eğer yüklü değilse)
   curl -fsSL https://get.docker.com | sh
   docker compose version  # Yüklendiğini doğrulayın
   ```
2. **Ollama Kurulumu** (Beyin):
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```
3. **Ollama'yı Dış Erişime Açma** (Kritik!):
   Varsayılan olarak Ollama sadece kendi bilgisayarınızı dinler. Docker konteynerinin de ona ulaşabilmesi için bu ayarı yapmalısınız.
   ```bash
   sudo mkdir -p /etc/systemd/system/ollama.service.d
   echo '[Service]
   Environment="OLLAMA_HOST=0.0.0.0"' | sudo tee /etc/systemd/system/ollama.service.d/override.conf
   sudo systemctl daemon-reload
   sudo systemctl restart ollama
   ```

---

## 🧠 Adım 2: Beyinleri İndirin (Modeller)
İki türe ihtiyacınız var: Biri zeka için, diğeri dökümanları okumak için.

1. **Kısıtlamasız Modeli İndir** (dolphin-llama3) - Güvenlik dersi vermeden soruları cevaplar:
   ```bash
   ollama pull dolphin-llama3
   ```
2. **Kütüphaneciyi İndir** (nomic-embed-text) - PDF kılavuzlarınızı organize eder:
   ```bash
   ollama pull nomic-embed-text
   ```

---

## 📦 Adım 3: "Civilization Node" Kurulumu
Şimdi bu depoyu kurun.

1. **Ortamı Ayarlayın**:
   ```bash
   cp .env.example .env
   # (İsteğe bağlı) Dosyaların nereye kaydedileceğini değiştirmek için .env dosyasını düzenleyin
   # Varsayılan konum: /opt/civilization
   ```
2. **Klasörleri Oluşturun**:
   ```bash
   ./setup_env.sh
   # Klasör oluşturmak için sudo izni isterse 'y' deyin.
   ```
3. **Arayüzü Başlatın**:
   ```bash
   docker compose up -d
   ```

---

## 📚 Adım 4: Bilgiyi İndirin (İnternet Arşivi)
Gerçek veriye ihtiyacınız var (Wikipedia, iFixit, vb.). Bu dosyalar büyüktür (100GB+).

1. **İndiriciyi Çalıştırın**:
   ```bash
   ./maintenance/list_available_content.sh
   ```
   *Ekranda çıkan menüden ZIM dosyalarını seçip indirin.*
2. **Önerilen İndirmeler**:
   - `wikipedia_tr_all_maxi` (Türkçe Vikipedi)
   - `wikipedia_en_all_nopic` (İngilizce Ansiklopedi - En kapsamlısı)
   - `ifixit_en_all` (Tamir kılavuzları)
   - `stackoverflow.com_en_all` (Yazılım/Mühendislik)
   - `wikisource_en_medicine` (Tıp kitapları)
   - `chemistry.stackexchange.com` (Kimyasal süreçler)

---

## 🚀 Adım 5: Kullanım
1. **Tarayıcınızı Açın**: [http://localhost:3000](http://localhost:3000)
2. **Model Seçin**: Üstteki menüden `dolphin-llama3` seçin.
3. **Aracı Bağlayın** (Wikipedia Erişimi İçin Gerekli):
   - **Workspace > Tools** menüsüne gidin.
   - "Kiwix" adında yeni bir araç oluşturun.
   - Bu repodaki **`kiwix_tool.py` dosyasının içeriğini kopyalayıp** oraya yapıştırın.
   - Kaydedin (Save).
   - **Önemli**: Yeni bir sohbet başlatırken (New Chat), sohbet ayarlarından "Kiwix" aracını aktif ettiğinizden emin olun!

Artık hazırsınız. Erişim onaylandı.

## ⚠️ Sorun Giderme
- **Yapay Zeka "No results found" diyor**: Ollama çalışmıyor veya 0.0.0.0 adresini dinlemiyor. Adım 1'deki ayarları tekrar yapın.
- **Kütüphane sürekli yeniden başlıyor**: Bir ZIM dosyası bozuk olabilir. `/opt/civilization/library/zims` içindeki son indirilen dosyayı silin.
