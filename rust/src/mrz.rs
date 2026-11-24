use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum MrzFormat {
    Td1, // 3 lines of 30 chars (ID cards)
    Td2, // 2 lines of 36 chars
    Td3, // 2 lines of 44 chars (Passports)
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MrzRecord {
    pub format: MrzFormat,
    pub document_type: String,
    pub issuing_country: String,
    pub document_number: String,
    pub document_number_valid: bool,
    pub nationality: String,
    pub birth_date: String,
    pub birth_date_valid: bool,
    pub sex: String,
    pub expiry_date: String,
    pub expiry_date_valid: bool,
    pub primary_identifier: String,   // Surname
    pub secondary_identifier: String, // Given names
    pub is_valid: bool,
}

pub struct MrzParser;

impl MrzParser {
    /// Computes the ICAO 9303 check digit with 7-3-1 weights.
    pub fn compute_check_digit(input: &str) -> u32 {
        let weights = [7, 3, 1];
        let mut sum = 0;
        for (i, ch) in input.chars().enumerate() {
            let val = match ch {
                '0'..='9' => ch as u32 - '0' as u32,
                'A'..='Z' => ch as u32 - 'A' as u32 + 10,
                _ => 0, // '<' or any other character is 0
            };
            sum += val * weights[i % 3];
        }
        sum % 10
    }

    /// Verifies if check digit matches expected digit.
    pub fn verify_check_digit(field: &str, check_char: char) -> bool {
        let expected = match check_char.to_digit(10) {
            Some(d) => d,
            None => return false,
        };
        Self::compute_check_digit(field) == expected
    }

    /// Cleans an MRZ line (uppercase, converts invalid spaces to '<').
    pub fn clean_line(line: &str) -> String {
        line.trim()
            .to_ascii_uppercase()
            .chars()
            .map(|c| if c.is_ascii_alphanumeric() || c == '<' { c } else { '<' })
            .collect()
    }

    /// Parses MRZ text block containing 2 or 3 lines.
    pub fn parse(text: &str) -> Option<MrzRecord> {
        let lines: Vec<String> = text
            .lines()
            .map(|l| Self::clean_line(l))
            .filter(|l| l.contains('<') && l.len() >= 28)
            .collect();

        if lines.len() == 2 && lines[0].len() == 44 && lines[1].len() == 44 {
            // TD3 (Passports)
            Self::parse_td3(&lines[0], &lines[1])
        } else if lines.len() == 3 && lines[0].len() == 30 && lines[1].len() == 30 && lines[2].len() == 30 {
            // TD1 (ID cards)
            Self::parse_td1(&lines[0], &lines[1], &lines[2])
        } else {
            None
        }
    }

    fn parse_td3(line1: &str, line2: &str) -> Option<MrzRecord> {
        let doc_type = line1.get(0..2)?.trim_end_matches('<').to_string();
        let issuing_country = line1.get(2..5)?.to_string();

        let names_part = line1.get(5..44)?;
        let mut name_parts = names_part.split("<<");
        let primary_id = name_parts.next().unwrap_or("").replace('<', " ").trim().to_string();
        let secondary_id = name_parts.next().unwrap_or("").replace('<', " ").trim().to_string();

        let doc_num = line2.get(0..9)?.trim_end_matches('<').to_string();
        let doc_num_check = line2.chars().nth(9)?;
        let doc_num_valid = Self::verify_check_digit(line2.get(0..9)?, doc_num_check);

        let nationality = line2.get(10..13)?.to_string();

        let birth_date = line2.get(13..19)?.to_string();
        let birth_check = line2.chars().nth(19)?;
        let birth_valid = Self::verify_check_digit(&birth_date, birth_check);

        let sex = line2.chars().nth(20)?.to_string();

        let expiry_date = line2.get(21..27)?.to_string();
        let expiry_check = line2.chars().nth(27)?;
        let expiry_valid = Self::verify_check_digit(&expiry_date, expiry_check);

        let is_valid = doc_num_valid && birth_valid && expiry_valid;

        Some(MrzRecord {
            format: MrzFormat::Td3,
            document_type: doc_type,
            issuing_country,
            document_number: doc_num,
            document_number_valid: doc_num_valid,
            nationality,
            birth_date,
            birth_date_valid: birth_valid,
            sex,
            expiry_date,
            expiry_date_valid: expiry_valid,
            primary_identifier: primary_id,
            secondary_identifier: secondary_id,
            is_valid,
        })
    }

    fn parse_td1(line1: &str, line2: &str, line3: &str) -> Option<MrzRecord> {
        let doc_type = line1.get(0..2)?.trim_end_matches('<').to_string();
        let issuing_country = line1.get(2..5)?.to_string();
        let doc_num = line1.get(5..14)?.trim_end_matches('<').to_string();
        let doc_num_check = line1.chars().nth(14)?;
        let doc_num_valid = Self::verify_check_digit(line1.get(5..14)?, doc_num_check);

        let birth_date = line2.get(0..6)?.to_string();
        let birth_check = line2.chars().nth(6)?;
        let birth_valid = Self::verify_check_digit(&birth_date, birth_check);

        let sex = line2.chars().nth(7)?.to_string();

        let expiry_date = line2.get(8..14)?.to_string();
        let expiry_check = line2.chars().nth(14)?;
        let expiry_valid = Self::verify_check_digit(&expiry_date, expiry_check);

        let nationality = line2.get(15..18)?.to_string();

        let mut name_parts = line3.split("<<");
        let primary_id = name_parts.next().unwrap_or("").replace('<', " ").trim().to_string();
        let secondary_id = name_parts.next().unwrap_or("").replace('<', " ").trim().to_string();

        let is_valid = doc_num_valid && birth_valid && expiry_valid;

        Some(MrzRecord {
            format: MrzFormat::Td1,
            document_type: doc_type,
            issuing_country,
            document_number: doc_num,
            document_number_valid: doc_num_valid,
            nationality,
            birth_date,
            birth_date_valid: birth_valid,
            sex,
            expiry_date,
            expiry_date_valid: expiry_valid,
            primary_identifier: primary_id,
            secondary_identifier: secondary_id,
            is_valid,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_mrz_check_digit() {
        assert_eq!(MrzParser::compute_check_digit("520727"), 3);
        assert!(MrzParser::verify_check_digit("520727", '3'));
    }

    #[test]
    fn test_mrz_td3_passport_parsing() {
        let line1 = "P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<";
        let line2 = "L898902C36UTO7408122F1204159ZE184226B<<<<<10";
        let res = MrzParser::parse(&format!("{}\n{}", line1, line2)).unwrap();

        assert_eq!(res.format, MrzFormat::Td3);
        assert_eq!(res.primary_identifier, "ERIKSSON");
        assert_eq!(res.secondary_identifier, "ANNA MARIA");
        assert_eq!(res.document_number, "L898902C3");
        assert!(res.document_number_valid);
    }
}
