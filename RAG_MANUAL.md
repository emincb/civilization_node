# RAG Pipeline Manual

This guide explains how to ingest documents and maintain the Vector Database for the Civilization Node.

## 1. Setup
Before first use, ensure the embedding model is active:
```bash
./rag_setup.sh
```
Then configure Open WebUI: **Admin Panel > Documents > Embedding Model > nomic-embed-text**.

## 2. Ingesting Documents
### Supported Formats
- **PDF**: Best for manuals and papers.
- **TXT/MD**: Good for notes.

### Process
1. **Drag & Drop**: Open the "Documents" tab in Open WebUI sidebar (`#`).
2. **Collection Tags**:
   - Always tag your uploads! Use `#manuals` for technical docs and `#research` for papers.
   - This allows targeted querying (e.g., "In #manuals, how do I reset the device?").
3. **Wait**:
   - Watch the progress bar.
   - Only upload 5-10 large PDFs at a time to prevent jamming the queue.

## 3. GPU Verification
To ensure your RTX 4070 is doing the work (not CPU):
1. Open a terminal during ingestion.
2. Run `watch -n 1 nvidia-smi`.
3. You should see a process for `ollama` with >1000MB VRAM and strict Compute usage.

## 4. Troubleshooting
**Issue: "Embedding generation failed"**
- Check model: `./rag_setup.sh`
- Check logs: `docker logs civ_ollama` (look for OOM errors).

**Issue: Search is slow**
- You might have too many small files. Try merging related PDFs.
- Ensure `nomic-embed-text` is being used (it's faster than larger models).
