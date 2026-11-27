use std::time::Instant;
use image::{DynamicImage, GenericImageView};
use crate::errors::{OcrError, Result};
use crate::models::{Block, BoundingBox, Line, OcrResult, Page, Point, Word};
use crate::preprocessing::{Preprocessor, PreprocessingMode};
use crate::quality::{QualityAnalyzer, QualityReport};
use crate::detection::LineDetector;
use crate::recognition::GlyphClassifier;

pub struct EngineConfig {
    pub languages: Vec<String>,
    pub confidence_threshold: f32,
    pub max_threads: usize,
    pub preprocessing_mode: PreprocessingMode,
}

impl Default for EngineConfig {
    fn default() -> Self {
        Self {
            languages: vec!["fr".to_string(), "en".to_string()],
            confidence_threshold: 0.5,
            max_threads: 4,
            preprocessing_mode: PreprocessingMode::Automatic,
        }
    }
}

pub struct OcrEngine {
    config: EngineConfig,
}

impl OcrEngine {
    pub fn new(config: EngineConfig) -> Self {
        Self { config }
    }

    pub fn analyze_quality(&self, img: &DynamicImage) -> QualityReport {
        QualityAnalyzer::analyze(img)
    }

    pub fn recognize(&self, img: &DynamicImage) -> Result<OcrResult> {
        let start = Instant::now();
        let (width, height) = img.dimensions();

        // 1. Preprocess image
        let _preprocessed = Preprocessor::process(img, self.config.preprocessing_mode);

        // 2. Detection & Recognition pipeline
        // Generates structured blocks, lines and words
        let blocks = self.run_pipeline(&_preprocessed)?;

        let full_text = blocks
            .iter()
            .map(|b| b.text.as_str())
            .collect::<Vec<_>>()
            .join("\n\n");

        let duration = start.elapsed().as_millis() as u64;

        let page = Page {
            page_number: 1,
            width,
            height,
            text: full_text.clone(),
            blocks: blocks.clone(),
        };

        let conf = if !blocks.is_empty() {
            let total: f32 = blocks.iter().filter_map(|b| b.confidence).sum();
            Some(total / blocks.len() as f32)
        } else {
            None
        };

        Ok(OcrResult {
            text: full_text,
            confidence: conf,
            processing_time_ms: duration,
            image_width: width,
            image_height: height,
            blocks,
            pages: vec![page],
        })
    }

    pub fn recognize_region(
        &self,
        img: &DynamicImage,
        x: f64,
        y: f64,
        w: f64,
        h: f64,
    ) -> Result<OcrResult> {
        let (img_w, img_h) = img.dimensions();

        if x < 0.0 || y < 0.0 || w <= 0.0 || h <= 0.0 || (x + w) > img_w as f64 || (y + h) > img_h as f64 {
            return Err(OcrError::InvalidRegion(x, y, w, h));
        }

        let cropped = img.crop_imm(x as u32, y as u32, w as u32, h as u32);
        self.recognize(&cropped)
    }

    fn run_pipeline(&self, img: &DynamicImage) -> Result<Vec<Block>> {
        let (width, height) = img.dimensions();
        if width == 0 || height == 0 {
            return Ok(Vec::new());
        }

        let detector = LineDetector::default();
        let classifier = GlyphClassifier::default();

        let line_regions = detector.detect_lines(img);
        if line_regions.is_empty() {
            return Ok(Vec::new());
        }

        let mut blocks = Vec::new();
        for (i, region) in line_regions.into_iter().enumerate() {
            let cropped = img.crop_imm(
                region.x as u32,
                region.y as u32,
                region.width as u32,
                region.height as u32,
            );

            let (text, words, conf) = classifier.recognize_line(&cropped);
            if text.trim().is_empty() {
                continue;
            }

            // Adjust word and character bounding boxes to absolute image coordinates
            let adjusted_words = words.into_iter().map(|mut w| {
                if let Some(ref mut bbox) = w.bounding_box {
                    bbox.x += region.x;
                    bbox.y += region.y;
                }
                for c in &mut w.characters {
                    if let Some(ref mut bbox) = c.bounding_box {
                        bbox.x += region.x;
                        bbox.y += region.y;
                    }
                }
                w
            }).collect::<Vec<_>>();

            let line = Line {
                text: text.clone(),
                confidence: Some(conf),
                bounding_box: Some(region.clone()),
                polygon: Some(vec![
                    Point { x: region.x, y: region.y },
                    Point { x: region.x + region.width, y: region.y },
                    Point { x: region.x + region.width, y: region.y + region.height },
                    Point { x: region.x, y: region.y + region.height },
                ]),
                words: adjusted_words,
            };

            let block = Block {
                id: format!("block_{}", i + 1),
                text,
                confidence: Some(conf),
                bounding_box: Some(region.clone()),
                polygon: Some(vec![
                    Point { x: region.x, y: region.y },
                    Point { x: region.x + region.width, y: region.y },
                    Point { x: region.x + region.width, y: region.y + region.height },
                    Point { x: region.x, y: region.y + region.height },
                ]),
                lines: vec![line],
                paragraphs: Vec::new(),
            };

            blocks.push(block);
        }

        Ok(blocks)
    }
}
