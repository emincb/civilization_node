# Kiwix Integration Guide for Open WebUI

## Overview
This guide explains how to register the "Kiwix Search" tool in your local Open WebUI instance. This allows models to search your offline ZIM files (Wikipedia, StackOverflow, etc.).

## Prerequisites
- Open WebUI running (`http://localhost:3000`)
- Kiwix Server running (`http://localhost:8080`)
- At least one ZIM file in `/opt/civilization/library/zims/` (and container restarted)

## Steps to Register Tool

1. **Access Open WebUI**
   Open your browser and navigate to [http://localhost:3000](http://localhost:3000).

2. **Open Workspace**
   Click on the **Workspace** icon in the sidebar (usually 4th icon down).

3. **Create New Tool**
   - Click **Tools** tab.
   - Click the **+** (Plus) button to create a new tool.

4. **Fill Details**
   - **Name**: `Kiwix Library`
   - **ID**: `kiwix_search`
   - **Description**: `Search offline Wikipedia and documentation.`

5. **Paste Code**
   Copy the content of `kiwix_tool.py` and paste it into the code editor area.
   
   *Note: Open WebUI tools run inside the Open WebUI container. The hostname `civ_library` used in the code resolves correctly because both containers share the `civilization_net` network.*

6. **Save**
   Click **Save & Update**.

## How to Use

1. **Enable Tool**: When starting a new chat, click the **+** (Plus) button next to the message input.
2. **Select Tool**: Toggle **Kiwix Library** on.
3. **Prompt**:
   - "Search the offline library for the history of the internet."
   - "Find python documentation for list comprehensions in the local wiki."
   
## Troubleshooting

**Error: "Connection refused"**
- Ensure the Kiwix container is running: `docker ps`
- Ensure `civ_library` is the correct container name in `docker-compose.yml`.

**Error: "No results found"**
- Verify you have ZIM files mounted: `ls /opt/civilization/library/zims`
- Restart Kiwix if you added files recently: `docker restart civ_library`
