use image::{DynamicImage, GrayImage, ImageBuffer, Luma};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PreprocessingMode {
    Automatic,
    Document,
    Photograph,
    LowLight,
    Receipt,
    IdentityDocument,
}

pub struct Preprocessor;

impl Preprocessor {
    /// Resizes an image keeping aspect ratio such that the max dimension is <= max_dim.
    pub fn resize_max_dimension(img: &DynamicImage, max_dim: u32) -> DynamicImage {
        let (width, height) = (img.width(), img.height());
        if width <= max_dim && height <= max_dim {
            return img.clone();
        }

        let ratio = if width > height {
            max_dim as f32 / width as f32
        } else {
            max_dim as f32 / height as f32
        };

        let new_w = (width as f32 * ratio).round() as u32;
        let new_h = (height as f32 * ratio).round() as u32;

        img.resize_exact(new_w, new_h, image::imageops::FilterType::Triangle)
    }

    /// Converts to grayscale.
    pub fn to_grayscale(img: &DynamicImage) -> GrayImage {
        img.to_luma8()
    }

    /// Simple adaptive binarization / thresholding (Otsu-inspired approximation).
    pub fn binarize(gray: &GrayImage) -> GrayImage {
        let mut histogram = [0u32; 256];
        let total = (gray.width() * gray.height()) as f32;

        for pixel in gray.pixels() {
            histogram[pixel[0] as usize] += 1;
        }

        // Calculate Otsu threshold
        let mut sum_all = 0.0;
        for i in 0..256 {
            sum_all += (i as f32) * (histogram[i] as f32);
        }

        let mut sum_b = 0.0;
        let mut w_b = 0.0;
        let mut max_variance = 0.0;
        let mut threshold = 128u8;

        for i in 0..256 {
            w_b += histogram[i] as f32;
            if w_b == 0.0 {
                continue;
            }
            let w_f = total - w_b;
            if w_f == 0.0 {
                break;
            }

            sum_b += (i as f32) * (histogram[i] as f32);
            let m_b = sum_b / w_b;
            let m_f = (sum_all - sum_b) / w_f;

            let between_var = w_b * w_f * (m_b - m_f) * (m_b - m_f);
            if between_var > max_variance {
                max_variance = between_var;
                threshold = i as u8;
            }
        }

        let mut bin_img = ImageBuffer::new(gray.width(), gray.height());
        for (x, y, pixel) in gray.enumerate_pixels() {
            let val = if pixel[0] >= threshold { 255 } else { 0 };
            bin_img.put_pixel(x, y, Luma([val]));
        }

        bin_img
    }

    /// Applies preprocessing pipeline according to selected profile.
    pub fn process(img: &DynamicImage, mode: PreprocessingMode) -> DynamicImage {
        match mode {
            PreprocessingMode::Automatic | PreprocessingMode::Document => {
                let resized = Self::resize_max_dimension(img, 2048);
                resized
            }
            PreprocessingMode::LowLight => {
                let brightened = img.brighten(20);
                Self::resize_max_dimension(&brightened, 2048)
            }
            PreprocessingMode::Receipt | PreprocessingMode::IdentityDocument => {
                let adjusted = img.adjust_contrast(15.0);
                Self::resize_max_dimension(&adjusted, 2048)
            }
            PreprocessingMode::Photograph => {
                Self::resize_max_dimension(img, 1920)
            }
        }
    }
}
