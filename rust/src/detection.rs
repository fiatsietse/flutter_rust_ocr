use crate::models::{BoundingBox, Point};

#[derive(Debug, Clone)]
pub struct DetectedBox {
    pub bounding_box: BoundingBox,
    pub polygon: Vec<Point>,
    pub score: f32,
}

pub struct DbNetPostProcessor {
    pub threshold: f32,
    pub box_threshold: f32,
    pub max_candidates: usize,
    pub unclip_ratio: f32,
}

impl Default for DbNetPostProcessor {
    fn default() -> Self {
        Self {
            threshold: 0.3,
            box_threshold: 0.6,
            max_candidates: 1000,
            unclip_ratio: 1.5,
        }
    }
}

impl DbNetPostProcessor {
    pub fn new(threshold: f32, box_threshold: f32, unclip_ratio: f32) -> Self {
        Self {
            threshold,
            box_threshold,
            max_candidates: 1000,
            unclip_ratio,
        }
    }

    /// Extracts text bounding boxes from a 2D probability map (H x W)
    pub fn process_prob_map(
        &self,
        prob_map: &[Vec<f32>],
        orig_width: u32,
        orig_height: u32,
    ) -> Vec<DetectedBox> {
        let h = prob_map.len();
        if h == 0 {
            return Vec::new();
        }
        let w = prob_map[0].len();
        if w == 0 {
            return Vec::new();
        }

        let scale_x = orig_width as f64 / w as f64;
        let scale_y = orig_height as f64 / h as f64;

        // 1. Thresholding to create binary mask
        let mut binary_mask = vec![vec![false; w]; h];
        for y in 0..h {
            for x in 0..w {
                if prob_map[y][x] >= self.threshold {
                    binary_mask[y][x] = true;
                }
            }
        }

        // 2. Connected Component extraction (grid scanning with BFS)
        let mut visited = vec![vec![false; w]; h];
        let mut detected_boxes = Vec::new();

        for y in 0..h {
            for x in 0..w {
                if binary_mask[y][x] && !visited[y][x] {
                    // Flood fill to discover component bounds
                    let mut min_x = x;
                    let mut max_x = x;
                    let mut min_y = y;
                    let mut max_y = y;
                    let mut total_prob = 0.0f32;
                    let mut pixel_count = 0;

                    let mut queue = std::collections::VecDeque::new();
                    queue.push_back((x, y));
                    visited[y][x] = true;

                    while let Some((cx, cy)) = queue.pop_front() {
                        pixel_count += 1;
                        total_prob += prob_map[cy][cx];

                        if cx < min_x { min_x = cx; }
                        if cx > max_x { max_x = cx; }
                        if cy < min_y { min_y = cy; }
                        if cy > max_y { max_y = cy; }

                        // 4-neighborhood
                        let neighbors = [
                            (cx.wrapping_sub(1), cy),
                            (cx + 1, cy),
                            (cx, cy.wrapping_sub(1)),
                            (cx, cy + 1),
                        ];

                        for &(nx, ny) in &neighbors {
                            if nx < w && ny < h && binary_mask[ny][nx] && !visited[ny][nx] {
                                visited[ny][nx] = true;
                                queue.push_back((nx, ny));
                            }
                        }
                    }

                    let avg_score = if pixel_count > 0 {
                        total_prob / pixel_count as f32
                    } else {
                        0.0
                    };

                    // Filter components by minimum area and average score threshold
                    let box_w = (max_x - min_x + 1) as f64;
                    let box_h = (max_y - min_y + 1) as f64;

                    if avg_score >= self.box_threshold && box_w >= 3.0 && box_h >= 3.0 {
                        // Apply unclip expansion
                        let expand_x = (box_w * (self.unclip_ratio as f64 - 1.0) / 2.0).max(1.0);
                        let expand_y = (box_h * (self.unclip_ratio as f64 - 1.0) / 2.0).max(1.0);

                        let final_min_x = ((min_x as f64 - expand_x) * scale_x).clamp(0.0, orig_width as f64);
                        let final_max_x = ((max_x as f64 + 1.0 + expand_x) * scale_x).clamp(0.0, orig_width as f64);
                        let final_min_y = ((min_y as f64 - expand_y) * scale_y).clamp(0.0, orig_height as f64);
                        let final_max_y = ((max_y as f64 + 1.0 + expand_y) * scale_y).clamp(0.0, orig_height as f64);

                        let polygon = vec![
                            Point { x: final_min_x, y: final_min_y },
                            Point { x: final_max_x, y: final_min_y },
                            Point { x: final_max_x, y: final_max_y },
                            Point { x: final_min_x, y: final_max_y },
                        ];

                        let bbox = BoundingBox::new(
                            final_min_x,
                            final_min_y,
                            final_max_x - final_min_x,
                            final_max_y - final_min_y,
                        );

                        detected_boxes.push(DetectedBox {
                            bounding_box: bbox,
                            polygon,
                            score: avg_score,
                        });

                        if detected_boxes.len() >= self.max_candidates {
                            return detected_boxes;
                        }
                    }
                }
            }
        }

        detected_boxes
    }
}

pub struct LineDetector {
    pub min_line_height: u32,
    pub max_line_height: u32,
}

impl Default for LineDetector {
    fn default() -> Self {
        Self {
            min_line_height: 8,
            max_line_height: 400,
        }
    }
}

impl LineDetector {
    pub fn new(min_line_height: u32, max_line_height: u32) -> Self {
        Self {
            min_line_height,
            max_line_height,
        }
    }

    /// Detects text lines in an image using horizontal & vertical projection profiles
    pub fn detect_lines(&self, img: &image::DynamicImage) -> Vec<BoundingBox> {
        use image::GenericImageView;
        let (width, height) = img.dimensions();
        if width < 10 || height < 8 {
            return Vec::new();
        }

        let gray = img.to_luma8();

        // 1. Determine background lightness from 4 border edges
        let mut border_sum = 0u64;
        let mut border_count = 0u64;
        for x in 0..width {
            border_sum += gray.get_pixel(x, 0)[0] as u64;
            border_sum += gray.get_pixel(x, height - 1)[0] as u64;
            border_count += 2;
        }
        for y in 1..height - 1 {
            border_sum += gray.get_pixel(0, y)[0] as u64;
            border_sum += gray.get_pixel(width - 1, y)[0] as u64;
            border_count += 2;
        }
        let avg_border = if border_count > 0 { (border_sum / border_count) as u8 } else { 255 };
        let is_light_bg = avg_border > 127;

        // 2. Compute horizontal projection of text pixels
        let mut row_activity = vec![0u32; height as usize];
        let diff_thresh = 30u8;

        for y in 0..height {
            let mut count = 0u32;
            for x in 0..width {
                let p = gray.get_pixel(x, y)[0];
                let is_text = if is_light_bg {
                    p < avg_border.saturating_sub(diff_thresh)
                } else {
                    p > avg_border.saturating_add(diff_thresh)
                };
                if is_text {
                    count += 1;
                }
            }
            if count >= (width / 120).max(4) {
                row_activity[y as usize] = count;
            }
        }

        // 3. Cluster contiguous rows into text bands
        let mut bands = Vec::new();
        let mut in_band = false;
        let mut start_y = 0u32;

        for y in 0..height {
            let active = row_activity[y as usize] > 0;
            if active && !in_band {
                in_band = true;
                start_y = y;
            } else if !active && in_band {
                in_band = false;
                let h = y - start_y;
                if h >= self.min_line_height && h <= self.max_line_height {
                    bands.push((start_y, y));
                }
            }
        }
        if in_band {
            let h = height - start_y;
            if h >= self.min_line_height && h <= self.max_line_height {
                bands.push((start_y, height));
            }
        }

        if bands.is_empty() {
            return vec![BoundingBox::new(0.0, 0.0, width as f64, height as f64)];
        }

        // 4. For each band, find horizontal left/right extent
        let mut result = Vec::new();
        for (y0, y1) in bands {
            let mut min_x = width;
            let mut max_x = 0;

            for y in y0..y1 {
                for x in 0..width {
                    let p = gray.get_pixel(x, y)[0];
                    let is_text = if is_light_bg {
                        p < avg_border.saturating_sub(diff_thresh)
                    } else {
                        p > avg_border.saturating_add(diff_thresh)
                    };
                    if is_text {
                        if x < min_x { min_x = x; }
                        if x > max_x { max_x = x; }
                    }
                }
            }

            if max_x > min_x && (max_x - min_x) >= 8 {
                let pad_x = ((max_x - min_x) / 50).max(2);
                let pad_y = 2;
                let fx = min_x.saturating_sub(pad_x) as f64;
                let fy = y0.saturating_sub(pad_y) as f64;
                let fw = ((max_x + pad_x).min(width) as f64 - fx).max(8.0);
                let fh = ((y1 + pad_y).min(height) as f64 - fy).max(8.0);

                result.push(BoundingBox::new(fx, fy, fw, fh));
            }
        }

        if result.is_empty() {
            vec![BoundingBox::new(0.0, 0.0, width as f64, height as f64)]
        } else {
            result
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_dbnet_postprocessing() {
        let processor = DbNetPostProcessor::default();
        // Create 20x20 probability map with a 5x5 region of 0.9
        let mut map = vec![vec![0.1f32; 20]; 20];
        for y in 5..10 {
            for x in 5..10 {
                map[y][x] = 0.95;
            }
        }

        let boxes = processor.process_prob_map(&map, 100, 100);
        assert_eq!(boxes.len(), 1);
        assert!(boxes[0].score >= 0.9);
        assert!(boxes[0].bounding_box.width > 20.0);
    }
}
