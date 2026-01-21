# Civilization Node 🌍

**A Self-Hosted, Offline-First Knowledge & AI Hub.**

The Civilization Node is a Dockerized system designed to provide access to the sum of human knowledge (Wikipedia, iFixit, Medical Databases) and advanced AI assistance (LLMs, RAG) in a completely offline environment. It is built to run on local hardware ("The Box") and serve users via a modern web interface.

## 🚀 Key Features

*   **Offline Library Search**: Instantly query terabytes of ZIM archives (Wikipedia, StackOverflow, etc.) using `kiwix-serve`.
*   **AI Access**: Run local LLMs (Llama 3, Mistral, Llava) using `Ollama`.
*   **Smart Integration**: A custom Open WebUI tool (`kiwix_tool.py`) allows the AI to "read" the offline library and answer questions with citations.
*   **Local RAG**: Upload private PDFs (manuals, documents) and chat with them using local embeddings.
*   **Zero-Dependency**: Does not require an internet connection once deployed.

## 🛠️ Tech Stack

*   **Core**: Docker Compose
*   **AI**: Ollama (Inference), Open WebUI (Interface)
*   **Knowledge**: Kiwix (ZIM Server)
*   **Tools**: Python (Search Tool), Rust (Content Processing), Shell (Maintenance)

## 📂 Repository Structure

*   `docker-compose.yml`: Main deployment definition.
*   `kiwix_tool.py`: The "Smart Search" tool for Open WebUI.
*   `download_content.py`: Script to fetch ZIM files from mirrors.
*   `maintenance/`: Scripts for system health, backups, and content updates.
*   `tools/`: Helper utilities (deduplication, validation).

## ⚡ Quick Start

1.  **Deploy Infrastructure**:
    ```bash
    docker compose up -d
    ```

2.  **Download Content**:
    ```bash
    # Downloads Wikipedia (WARNING: huge download)
    python3 download_content.py --path wikipedia
    ```

3.  **Install AI Tool**:
    Copy the contents of `kiwix_tool.py` into Open WebUI > Workspace > Tools > "Kiwix Knowledge Retrieval".

4.  **Access**:
    Open `http://localhost:3000` and start chatting.

## 📖 Documentation
*   [Deployment Guide](DEPLOYMENT_GUIDE.md)
*   [Operations Runbook](OPERATIONS_RUNBOOK.md)
*   [Kiwix Integration Guide](KIWIX_INTEGRATION_GUIDE.md)

## 🛡️ License
MIT License.
