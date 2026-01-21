# Civilization Node: Phase 1 Deployment Guide

This guide walks you through the initial infrastructure setup for the Civilization Node.

## Prerequisites
- Ubuntu 22.04 LTS
- NVIDIA RTX 4070 (Drivers installed)
- Sudo access

## Step 1: Environment Setup
Run the setup script to verify requirements and create the necessary directory structure at `/opt/civilization`.

```bash
chmod +x setup_env.sh
./setup_env.sh
```
*Note: You will be prompted to allow `sudo` commands for directory creation.*

**Success Indicator:** 
- Output shows `[OK]` for all checks.
- Directories in `/opt/civilization/` are created and owned by your user.

## Step 2: Launch Services
Start the Docker stack.

```bash
docker compose up -d
```

**Success Indicator:**
- Docker pulls images (Ollama, Open WebUI, Kiwix).
- Containers `civ_ollama`, `civ_webui`, and `civ_library` start.

## Step 3: Verification
Run the verification script to ensure systems are operational and the GPU is accessible.

```bash
chmod +x verify_deployment.sh
./verify_deployment.sh
```

**Success Indicator:**
- All services respond (HTTP 200/OK).
- GPU check inside Ollama passes.

## Step 4: First Access
1. **Open WebUI**: [http://localhost:3000](http://localhost:3000)
   - Create the first admin account (this remains offline/local).
2. **Kiwix Library**: [http://localhost:8080](http://localhost:8080)
   - *Note: It will be empty until you add ZIM files to `/opt/civilization/library/zims` and restart the container.*

## Troubleshooting
**Issue: Nvidia Container Runtime Missing**
If Ollama fails to start with a GPU error:
1. Ensure `nvidia-container-toolkit` is installed.
2. Run: `sudo nvidia-ctk runtime configure --runtime=docker`
3. Run: `sudo systemctl restart docker`

**Issue: Permission Denied on Volumes**
If containers crash immediately:
1. Check permissions: `ls -ld /opt/civilization/models`
2. Fix: `sudo chown -R $USER:$USER /opt/civilization`
