use thiserror::Error;

#[derive(Error, Debug)]
pub enum OcrError {
    #[error("Image error: {0}")]
    ImageError(String),

    #[error("Invalid region: x={0}, y={1}, w={2}, h={3}")]
    InvalidRegion(f64, f64, f64, f64),

    #[error("Model not found: {0}")]
    ModelNotFound(String),

    #[error("Model integrity check failed for {0}: expected {1}, got {2}")]
    ModelIntegrityError(String, String, String),

    #[error("Inference failed: {0}")]
    InferenceError(String),

    #[error("Serialization error: {0}")]
    SerializationError(String),

    #[error("Unsupported operation: {0}")]
    Unsupported(String),
}

pub type Result<T> = std::result::Result<T, OcrError>;
