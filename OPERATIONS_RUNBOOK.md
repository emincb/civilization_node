# Civilization Node: Operations Runbook

## 1. Monitoring & Health
**Routine:** Weekly
- **Command:** `./maintenance/master_check.sh`
- **Success:** Output says "ALL SYSTEMS OPERATIONAL".
- **Failure:** Check `docker logs <container_name>`.

## 2. Adding New Content
**Routine:** Ad-hoc
1. Copy new ZIM/PDF files to `/opt/civilization/incoming/`.
2. Run `./maintenance/update_content.sh`
3. Follow the interactive prompts to categorize content.
4. The script automatically restarts Kiwix to load new ZIMs.

## 3. Backups
**Routine:** Weekly (Can be cron-scheduled)
- **Command:** `./maintenance/backup_system.sh`
- **Storage:** Backups are stored in `/opt/civilization/backups/`.
- **Recommendation:** Periodically copy the latest backup folder to an external USB drive.

## 4. Disaster Recovery
**Scenario:** SSD Failure / Complete Reinstall
1. Install Ubuntu 22.04 & NVIDIA Drivers & Docker.
2. Run `setup_env.sh` to recreate directory structure.
3. Restore Data:
   ```bash
   # Copy backup folder back
   tar -xzf openwebui_data.tar.gz -C /opt/civilization/
   ```
4. Restore Content using `civ_ingest.sh` (or bulk copy to `/opt/civilization/library`).
5. Launch Stack: `docker compose up -d`
6. Verify: `maintenance/master_check.sh`
