use std::env;
use std::fs::File;
use std::io::{self, Read};
use std::path::Path;
use walkdir::WalkDir;
use serde::Serialize;

#[derive(Serialize)]
struct ValidationResult {
    path: String,
    status: String, // "valid", "invalid", "unknown"
    error: Option<String>,
}

fn check_pdf(path: &Path) -> io::Result<bool> {
    let mut file = File::open(path)?;
    let mut buffer = [0; 5];
    file.read_exact(&mut buffer)?;
    Ok(&buffer == b"%PDF-")
}

fn check_zim(path: &Path) -> io::Result<bool> {
    let mut file = File::open(path)?;
    let mut buffer = [0; 4];
    file.read_exact(&mut buffer)?;
    // ZIM file magic bytes: 'Z', 'I', 'M', '\x04' (usually)
    // We'll just check ZIM for now to be safe across versions
    Ok(&buffer[0..3] == b"ZIM")
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: civ_validate <directory>");
        std::process::exit(1);
    }

    let root_dir = &args[1];
    let mut results = Vec::new();

    eprintln!("Validating files in {}...", root_dir);

    for entry in WalkDir::new(root_dir).into_iter().filter_map(|e| e.ok()) {
        if !entry.file_type().is_file() {
            continue;
        }

        let path = entry.path();
        let path_str = path.to_string_lossy().to_string();
        let extension = path.extension().and_then(|s| s.to_str()).unwrap_or("").to_lowercase();

        let (is_valid, error) = match extension.as_str() {
            "pdf" => match check_pdf(path) {
                Ok(valid) => (valid, None),
                Err(e) => (false, Some(e.to_string())),
            },
            "zim" => match check_zim(path) {
                Ok(valid) => (valid, None),
                Err(e) => (false, Some(e.to_string())),
            },
            _ => (true, Some("Skipped (unknown type)".to_string())), // unknown types are 'valid' but skipped
        };

        if !is_valid || (extension == "pdf" || extension == "zim") {
             // Only report if it's a target type or invalid
             results.push(ValidationResult {
                 path: path_str,
                 status: if is_valid { "valid".to_string() } else { "invalid".to_string() },
                 error,
             });
        }
    }

    let json_output = serde_json::to_string_pretty(&results).unwrap();
    println!("{}", json_output);
}
