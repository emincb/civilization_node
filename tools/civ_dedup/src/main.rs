use sha2::{Digest, Sha256};
use std::collections::HashMap;
use std::env;
use std::fs::{self, File};
use std::io::{self, Read};
use std::path::Path;
use walkdir::WalkDir;
use serde::Serialize;

#[derive(Serialize)]
struct DuplicateGroup {
    hash: String,
    files: Vec<String>,
}

fn calculate_hash(path: &Path) -> io::Result<String> {
    let mut file = File::open(path)?;
    let mut hasher = Sha256::new();
    let mut buffer = [0; 8192];

    loop {
        let count = file.read(&mut buffer)?;
        if count == 0 {
            break;
        }
        hasher.update(&buffer[..count]);
    }

    Ok(hex::encode(hasher.finalize()))
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: civ_dedup <directory>");
        std::process::exit(1);
    }

    let root_dir = &args[1];
    let mut hashes: HashMap<String, Vec<String>> = HashMap::new();

    eprintln!("Scanning {}...", root_dir);

    for entry in WalkDir::new(root_dir).into_iter().filter_map(|e| e.ok()) {
        if !entry.file_type().is_file() {
            continue;
        }

        let path = entry.path();
        match calculate_hash(path) {
            Ok(hash) => {
                hashes.entry(hash).or_default().push(path.to_string_lossy().into_owned());
            }
            Err(e) => eprintln!("Error reading {:?}: {}", path, e),
        }
    }

    let duplicates: Vec<DuplicateGroup> = hashes
        .into_iter()
        .filter(|(_, paths)| paths.len() > 1)
        .map(|(hash, files)| DuplicateGroup { hash, files })
        .collect();

    let json_output = serde_json::to_string_pretty(&duplicates).unwrap();
    println!("{}", json_output);
    
    eprintln!("Found {} groups of duplicates.", duplicates.len());
}
