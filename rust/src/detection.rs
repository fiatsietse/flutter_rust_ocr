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
