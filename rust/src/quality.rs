use serde::{Deserialize, Serialize};
use image::{DynamicImage, GenericImageView, GrayImage, Luma};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct QualityReport {
    pub is_acceptable: bool,
    pub blur_score: f64,
    pub brightness_score: f64,
    pub contrast_score: f64,
    pub resolution_score: f64,
    pub recommendations: Vec<String>,
}

pub struct QualityAnalyzer;

impl QualityAnalyzer {
    pub fn analyze(img: &DynamicImage) -> QualityReport {
        let (width, height) = img.dimensions();
        let gray: GrayImage = img.to_luma8();
        let total_pixels = (width * height) as f64;

        if total_pixels == 0.0 {
            return QualityReport {
                is_acceptable: false,
                blur_score: 0.0,
                brightness_score: 0.0,
                contrast_score: 0.0,
                resolution_score: 0.0,
                recommendations: vec!["Image has zero dimensions".to_string()],
            };
        }

        // 1. Mean brightness
        let mut sum_brightness = 0.0;
        for pixel in gray.pixels() {
            sum_brightness += pixel[0] as f64;
        }
        let mean_brightness = sum_brightness / total_pixels; // 0..255

        // 2. Contrast (standard deviation)
        let mut sum_variance = 0.0;
        for pixel in gray.pixels() {
            let diff = pixel[0] as f64 - mean_brightness;
            sum_variance += diff * diff;
        }
        let std_dev = (sum_variance / total_pixels).sqrt(); // 0..128 approx

        // 3. Blur score using gradient variance (Laplacian approximation)
        let mut laplacian_sum = 0.0;
        let mut count = 0.0;
        for y in 1..(height - 1) {
            for x in 1..(width - 1) {
                let center = gray.get_pixel(x, y)[0] as f64;
                let top = gray.get_pixel(x, y - 1)[0] as f64;
                let bottom = gray.get_pixel(x, y + 1)[0] as f64;
                let left = gray.get_pixel(x - 1, y)[0] as f64;
                let right = gray.get_pixel(x + 1, y)[0] as f64;

                let lap = (top + bottom + left + right - 4.0 * center).abs();
                laplacian_sum += lap;
                count += 1.0;
            }
        }
        let blur_metric = if count > 0.0 { laplacian_sum / count } else { 0.0 };

        // Normalize scores to [0.0, 1.0]
        let brightness_norm = (1.0 - (mean_brightness - 128.0).abs() / 128.0).clamp(0.0, 1.0);
        let contrast_norm = (std_dev / 64.0).clamp(0.0, 1.0);
        let blur_norm = (blur_metric / 20.0).clamp(0.0, 1.0);
        let resolution_norm = if width >= 1024 && height >= 768 {
            1.0
        } else {
            ((width * height) as f64 / (1024.0 * 768.0)).clamp(0.1, 1.0)
        };

        let mut recommendations = Vec::new();
        if mean_brightness < 40.0 {
            recommendations.push("Image too dark. Increase lighting.".to_string());
        } else if mean_brightness > 220.0 {
            recommendations.push("Image overexposed. Reduce glare.".to_string());
        }

        if contrast_norm < 0.25 {
            recommendations.push("Low contrast detected.".to_string());
        }

        if blur_norm < 0.2 {
            recommendations.push("Image is blurry. Please hold camera steady.".to_string());
        }

        if resolution_norm < 0.4 {
            recommendations.push("Resolution is low. Move closer to the text.".to_string());
        }

        let is_acceptable = recommendations.len() <= 1 && blur_norm >= 0.15;

        QualityReport {
            is_acceptable,
            blur_score: blur_norm,
            brightness_score: brightness_norm,
            contrast_score: contrast_norm,
            resolution_score: resolution_norm,
            recommendations,
        }
    }
}
