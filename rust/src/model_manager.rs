use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use crate::errors::{OcrError, Result};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModelManifestItem {
    pub id: String,
    pub version: String,
    pub model_type: String, // "detection", "recognition", "classifier"
    pub languages: Vec<String>,
    pub size_bytes: u64,
    pub sha256: String,
    pub filename: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModelManifest {
    pub version: String,
    pub models: Vec<ModelManifestItem>,
}

pub struct ModelManager;

impl ModelManager {
    /// Computes the SHA-256 hash of a byte slice.
    pub fn compute_sha256(data: &[u8]) -> String {
        let mut hasher = Sha256::new();
        hasher.update(data);
        format!("{:x}", hasher.finalize())
    }

    /// Validates model integrity against the expected SHA-256 hash.
    pub fn verify_integrity(model_id: &str, data: &[u8], expected_sha256: &str) -> Result<()> {
        let computed = Self::compute_sha256(data);
        if !computed.eq_ignore_ascii_case(expected_sha256) {
            return Err(OcrError::ModelIntegrityError(
                model_id.to_string(),
                expected_sha256.to_string(),
                computed,
            ));
        }
        Ok(())
    }

    /// Parses a manifest JSON string.
    pub fn parse_manifest(json_str: &str) -> Result<ModelManifest> {
        serde_json::from_str(json_str)
            .map_err(|e| OcrError::SerializationError(e.to_string()))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_sha256_computation() {
        let data = b"paddleocr_ch_PP-OCRv4_rec";
        let hash = ModelManager::compute_sha256(data);
        assert!(!hash.is_empty());
        assert_eq!(hash.len(), 64);

        let res = ModelManager::verify_integrity("test_model", data, &hash);
        assert!(res.is_ok());

        let bad_res = ModelManager::verify_integrity("test_model", data, "0000000000000000000000000000000000000000000000000000000000000000");
        assert!(bad_res.is_err());
    }
}
