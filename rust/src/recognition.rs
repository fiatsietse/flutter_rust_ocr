use crate::errors::{OcrError, Result};

pub struct CtcDecoder {
    characters: Vec<char>,
}

impl CtcDecoder {
    /// Initializes CTC decoder with a character dictionary.
    /// Index 0 is reserved for CTC blank symbol.
    pub fn new(dictionary_chars: Vec<char>) -> Self {
        let mut characters = Vec::with_capacity(dictionary_chars.len() + 1);
        characters.push(' '); // blank token placeholder
        characters.extend(dictionary_chars);
        Self { characters }
    }

    /// Default French + English alphanumeric and punctuation dictionary.
    pub fn default_latin() -> Self {
        let alphabet = " 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
            .to_string()
            + "àâéèêëîïôùûüçœæÀÂÉÈÊËÎÏÔÙÛÜÇŒÆ"
            + "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~€$£°";
        Self::new(alphabet.chars().collect())
    }

    /// Decodes a 2D matrix of shape `[timesteps, num_classes]` into (text, confidence).
    pub fn decode_greedy(&self, probabilities: &[Vec<f32>]) -> (String, f32) {
        if probabilities.is_empty() {
            return (String::new(), 0.0);
        }

        let mut decoded_text = String::new();
        let mut last_index: usize = 0;
        let mut total_confidence = 0.0f32;
        let mut char_count = 0;

        for timestep in probabilities {
            if timestep.is_empty() {
                continue;
            }

            // Find argmax
            let mut max_idx = 0;
            let mut max_prob = timestep[0];
            for (idx, &prob) in timestep.iter().enumerate() {
                if prob > max_prob {
                    max_prob = prob;
                    max_idx = idx;
                }
            }

            // CTC rules:
            // 0 is blank
            // Repeated characters are collapsed unless separated by blank
            if max_idx != 0 && max_idx != last_index {
                if let Some(&ch) = self.characters.get(max_idx) {
                    decoded_text.push(ch);
                    total_confidence += max_prob;
                    char_count += 1;
                }
            }
            last_index = max_idx;
        }

        let avg_confidence = if char_count > 0 {
            total_confidence / char_count as f32
        } else {
            0.0
        };

        (decoded_text, avg_confidence)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ctc_decoding_basic() {
        let decoder = CtcDecoder::default_latin();
        // Construct synthetic logits for "a", blank, "a"
        // Let's find index of 'a'
        let a_idx = decoder.characters.iter().position(|&c| c == 'a').unwrap();

        let num_classes = decoder.characters.len();
        let mut frame_a = vec![0.01f32; num_classes];
        frame_a[a_idx] = 0.98;

        let mut frame_blank = vec![0.01f32; num_classes];
        frame_blank[0] = 0.99; // blank

        // Sequence: a, a, blank, a -> "aa"
        let probs = vec![
            frame_a.clone(),
            frame_a.clone(),
            frame_blank.clone(),
            frame_a.clone(),
        ];

        let (text, conf) = decoder.decode_greedy(&probs);
        assert_eq!(text, "aa");
        assert!(conf > 0.9);
    }

    #[test]
    fn test_ctc_decoding_french_accents() {
        let decoder = CtcDecoder::default_latin();
        let e_idx = decoder.characters.iter().position(|&c| c == 'é').unwrap();
        let num_classes = decoder.characters.len();

        let mut frame_e = vec![0.01f32; num_classes];
        frame_e[e_idx] = 0.95;

        let probs = vec![frame_e];
        let (text, conf) = decoder.decode_greedy(&probs);
        assert_eq!(text, "é");
        assert!(conf > 0.9);
    }
}
