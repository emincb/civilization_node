# Civilization Node: Content Organization Manual

This document defines the strict standards for file organization within the Civilization Node. These standards ensure the library remains browseable and maintainable indefinitely.

## 1. Directory Structure

The root directory is `/opt/civilization/library`.

```
/opt/civilization/
├── incoming/                   # LANDING ZONE: All new files go here first
├── library/
│   ├── zims/                   # Kiwix ZIM files
│   │   ├── encyclopedia/       # Wikipedia, Britannica, etc.
│   │   ├── tech/               # StackOverflow, ArchWiki, etc.
│   │   ├── books/              # Project Gutenberg, etc.
│   │   └── other/              # Uncategorized ZIMs
│   └── pdfs/                   # PDF Documents
│       ├── manuals/            # Technical manuals, datasheets
│       ├── research/           # You, papers, academic articles
│       ├── books/              # E-books, non-technical reading
│       └── uncategorized/      # Default for fast ingestion
└── models/                     # LLM Models (Ollama)
```

## 2. Naming Conventions

### ZIM Files
Format: `[Source]_[Language]_[Topic]_[Date].zim`
Examples:
- `wikipedia_en_all_2024-01.zim`
- `stackoverflow_en_python_2023-12.zim`
- `archlinux_en_wiki_2024-02.zim`

### PDF Files
Format: `[category]_[author/org]_[title_slug]_[year].pdf`
Rules:
- **Lowercase** only.
- **Snake_case** (underscores, no spaces).
- **Date** is year only (YYYY).
- **Category** matches a subfolder in `library/pdfs/`.

Examples:
- `manuals_sony_wh1000xm4_guide_2020.pdf`
- `research_google_attention_is_all_you_need_2017.pdf`
- `books_orwell_1984_1949.pdf`

## 3. Workflow

1. **Acquisition**: User copies file to `/opt/civilization/incoming/`.
2. **Ingestion**: User runs `civ_ingest.sh`.
   - Script asks for file type (ZIM/PDF).
   - Script asks for metadata to build the standardized name.
   - Script moves file to final destination.
   - Script sets permissions (Owner: Current User, Group: Current User, Mode: 644).
3. **Maintenance**: User runs `civ_maintenance.sh` periodically to check for misplaced files.
