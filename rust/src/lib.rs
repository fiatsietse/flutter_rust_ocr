pub mod errors;
pub mod models;
pub mod preprocessing;
pub mod quality;
pub mod extraction;
pub mod engine;
pub mod detection;
pub mod recognition;
pub mod model_manager;
pub mod mrz;

use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::sync::Mutex;
use lazy_static::lazy_static;

use crate::engine::{EngineConfig, OcrEngine};
use crate::extraction::{DocumentExtractor, DocumentTemplate};
use crate::preprocessing::PreprocessingMode;

lazy_static! {
    static ref GLOBAL_ENGINE: Mutex<Option<OcrEngine>> = Mutex::new(None);
}

/// Initializes the global OCR engine with JSON configuration.
/// Returns 0 on success, negative error code on failure.
#[no_mangle]
pub extern "C" fn ocr_engine_init(config_json: *const c_char) -> i32 {
    let _cfg_str = if config_json.is_null() {
        ""
    } else {
        unsafe {
            match CStr::from_ptr(config_json).to_str() {
                Ok(s) => s,
                Err(_) => return -1,
            }
        }
    };

    let config = EngineConfig {
        languages: vec!["fr".to_string(), "en".to_string()],
        confidence_threshold: 0.5,
        max_threads: 4,
        preprocessing_mode: PreprocessingMode::Automatic,
    };

    let mut lock = match GLOBAL_ENGINE.lock() {
        Ok(l) => l,
        Err(_) => return -2,
    };

    *lock = Some(OcrEngine::new(config));
    0
}

/// Frees the global engine resources.
#[no_mangle]
pub extern "C" fn ocr_engine_dispose() -> i32 {
    let mut lock = match GLOBAL_ENGINE.lock() {
        Ok(l) => l,
        Err(_) => return -1,
    };
    *lock = None;
    0
}

/// Evaluates image quality and returns a JSON string.
/// The returned pointer must be freed with `ocr_free_string`.
#[no_mangle]
pub extern "C" fn ocr_analyze_quality_bytes(
    bytes: *const u8,
    len: usize,
) -> *mut c_char {
    if bytes.is_null() || len == 0 {
        return std::ptr::null_mut();
    }

    let slice = unsafe { std::slice::from_raw_parts(bytes, len) };
    let img = match image::load_from_memory(slice) {
        Ok(i) => i,
        Err(_) => return std::ptr::null_mut(),
    };

    let report = quality::QualityAnalyzer::analyze(&img);
    let json = match serde_json::to_string(&report) {
        Ok(j) => j,
        Err(_) => return std::ptr::null_mut(),
    };

    match CString::new(json) {
        Ok(c) => c.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Performs OCR on image bytes and returns JSON serialized OcrResult.
/// The returned pointer must be freed with `ocr_free_string`.
#[no_mangle]
pub extern "C" fn ocr_recognize_bytes(
    bytes: *const u8,
    len: usize,
) -> *mut c_char {
    if bytes.is_null() || len == 0 {
        return std::ptr::null_mut();
    }

    let slice = unsafe { std::slice::from_raw_parts(bytes, len) };
    let img = match image::load_from_memory(slice) {
        Ok(i) => i,
        Err(e) => {
            let err_json = format!(r#"{{"error":"Failed to decode image: {}"}}"#, e);
            return CString::new(err_json).unwrap().into_raw();
        }
    };

    let lock = match GLOBAL_ENGINE.lock() {
        Ok(l) => l,
        Err(_) => return std::ptr::null_mut(),
    };

    let engine = match lock.as_ref() {
        Some(e) => e,
        None => return std::ptr::null_mut(),
    };

    match engine.recognize(&img) {
        Ok(res) => {
            let json = serde_json::to_string(&res).unwrap_or_default();
            CString::new(json).unwrap().into_raw()
        }
        Err(e) => {
            let err_json = format!(r#"{{"error":"{}"}}"#, e);
            CString::new(err_json).unwrap().into_raw()
        }
    }
}

/// Performs structured document extraction on OCR text according to template JSON.
#[no_mangle]
pub extern "C" fn ocr_extract_document_template(
    ocr_text_ptr: *const c_char,
    template_json_ptr: *const c_char,
) -> *mut c_char {
    if ocr_text_ptr.is_null() || template_json_ptr.is_null() {
        return std::ptr::null_mut();
    }

    let ocr_text = unsafe {
        match CStr::from_ptr(ocr_text_ptr).to_str() {
            Ok(s) => s,
            Err(_) => return std::ptr::null_mut(),
        }
    };

    let template_json = unsafe {
        match CStr::from_ptr(template_json_ptr).to_str() {
            Ok(s) => s,
            Err(_) => return std::ptr::null_mut(),
        }
    };

    let template: DocumentTemplate = match serde_json::from_str(template_json) {
        Ok(t) => t,
        Err(_) => return std::ptr::null_mut(),
    };

    let result = DocumentExtractor::extract(ocr_text, &template);
    let json = serde_json::to_string(&result).unwrap_or_default();
    CString::new(json).unwrap().into_raw()
}

/// Frees a string allocated by the Rust library.
#[no_mangle]
pub extern "C" fn ocr_free_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use image::{Rgb, RgbImage};

    #[test]
    fn test_quality_analysis() {
        let img = DynamicImage::ImageRgb8(RgbImage::from_pixel(100, 100, Rgb([128, 128, 128])));
        let report = quality::QualityAnalyzer::analyze(&img);
        assert!(report.blur_score >= 0.0);
        assert!(report.brightness_score > 0.0);
    }

    #[test]
    fn test_document_extraction() {
        let template = DocumentTemplate {
            id: "invoice".to_string(),
            version: "1.0".to_string(),
            name: "Facture".to_string(),
            fields: vec![extraction::FieldDefinition {
                name: "invoice_number".to_string(),
                field_type: "string".to_string(),
                required: true,
                labels: vec!["Facture N°:".to_string(), "Facture:".to_string()],
                pattern: None,
            }],
        };

        let ocr_text = "Société Exemple\nFacture N°: FAC-2026-001\nTotal: 100 EUR";
        let res = DocumentExtractor::extract(ocr_text, &template);
        assert_eq!(res.template_id, "invoice");
        assert!(res.is_complete);
        assert_eq!(res.fields.get("invoice_number").unwrap().raw_value, "FAC-2026-001");
    }
}
