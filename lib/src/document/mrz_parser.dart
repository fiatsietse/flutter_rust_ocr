import 'package:flutter/foundation.dart';

enum MrzFormat { td1, td2, td3 }

@immutable
class MrzResult {
  final MrzFormat format;
  final String documentType;
  final String issuingCountry;
  final String documentNumber;
  final bool isDocumentNumberValid;
  final String nationality;
  final String birthDate;
  final bool isBirthDateValid;
  final String sex;
  final String expiryDate;
  final bool isExpiryDateValid;
  final String surname;
  final String givenNames;
  final bool isValid;

  const MrzResult({
    required this.format,
    required this.documentType,
    required this.issuingCountry,
    required this.documentNumber,
    required this.isDocumentNumberValid,
    required this.nationality,
    required this.birthDate,
    required this.isBirthDateValid,
    required this.sex,
    required this.expiryDate,
    required this.isExpiryDateValid,
    required this.surname,
    required this.givenNames,
    required this.isValid,
  });

  Map<String, dynamic> toJson() => {
    'format': format.name,
    'documentType': documentType,
    'issuingCountry': issuingCountry,
    'documentNumber': documentNumber,
    'isDocumentNumberValid': isDocumentNumberValid,
    'nationality': nationality,
    'birthDate': birthDate,
    'isBirthDateValid': isBirthDateValid,
    'sex': sex,
    'expiryDate': expiryDate,
    'isExpiryDateValid': isExpiryDateValid,
    'surname': surname,
    'givenNames': givenNames,
    'isValid': isValid,
  };
}

class MrzParser {
  static const List<int> _weights = [7, 3, 1];

  static int computeCheckDigit(String input) {
    int sum = 0;
    for (int i = 0; i < input.length; i++) {
      final code = input.codeUnitAt(i);
      int val = 0;
      if (code >= 48 && code <= 57) {
        val = code - 48; // '0'-'9'
      } else if (code >= 65 && code <= 90) {
        val = code - 65 + 10; // 'A'-'Z'
      }
      sum += val * _weights[i % 3];
    }
    return sum % 10;
  }

  static bool verifyCheckDigit(String field, String checkChar) {
    final digit = int.tryParse(checkChar);
    if (digit == null) return false;
    return computeCheckDigit(field) == digit;
  }

  static String _cleanLine(String line) {
    return line.trim().toUpperCase().replaceAll(' ', '<');
  }

  static MrzResult? parse(String rawText) {
    final lines = rawText
        .split('\n')
        .map(_cleanLine)
        .where((l) => l.contains('<') && l.length >= 28)
        .toList();

    if (lines.length == 2 && lines[0].length == 44 && lines[1].length == 44) {
      return _parseTd3(lines[0], lines[1]);
    } else if (lines.length == 3 &&
        lines[0].length == 30 &&
        lines[1].length == 30 &&
        lines[2].length == 30) {
      return _parseTd1(lines[0], lines[1], lines[2]);
    }
    return null;
  }

  static MrzResult? _parseTd3(String l1, String l2) {
    final docType = l1.substring(0, 2).replaceAll('<', '').trim();
    final country = l1.substring(2, 5);
    final nameParts = l1.substring(5, 44).split('<<');
    final surname = nameParts.isNotEmpty ? nameParts[0].replaceAll('<', ' ').trim() : '';
    final givenNames = nameParts.length > 1 ? nameParts[1].replaceAll('<', ' ').trim() : '';

    final docNum = l2.substring(0, 9).replaceAll('<', '').trim();
    final docNumValid = verifyCheckDigit(l2.substring(0, 9), l2[9]);

    final nationality = l2.substring(10, 13);
    final birthDate = l2.substring(13, 19);
    final birthValid = verifyCheckDigit(birthDate, l2[19]);

    final sex = l2[20];
    final expiryDate = l2.substring(21, 27);
    final expiryValid = verifyCheckDigit(expiryDate, l2[27]);

    final isValid = docNumValid && birthValid && expiryValid;

    return MrzResult(
      format: MrzFormat.td3,
      documentType: docType,
      issuingCountry: country,
      documentNumber: docNum,
      isDocumentNumberValid: docNumValid,
      nationality: nationality,
      birthDate: birthDate,
      isBirthDateValid: birthValid,
      sex: sex,
      expiryDate: expiryDate,
      isExpiryDateValid: expiryValid,
      surname: surname,
      givenNames: givenNames,
      isValid: isValid,
    );
  }

  static MrzResult? _parseTd1(String l1, String l2, String l3) {
    final docType = l1.substring(0, 2).replaceAll('<', '').trim();
    final country = l1.substring(2, 5);
    final docNum = l1.substring(5, 14).replaceAll('<', '').trim();
    final docNumValid = verifyCheckDigit(l1.substring(5, 14), l1[14]);

    final birthDate = l2.substring(0, 6);
    final birthValid = verifyCheckDigit(birthDate, l2[6]);
    final sex = l2[7];
    final expiryDate = l2.substring(8, 14);
    final expiryValid = verifyCheckDigit(expiryDate, l2[14]);
    final nationality = l2.substring(15, 18);

    final nameParts = l3.split('<<');
    final surname = nameParts.isNotEmpty ? nameParts[0].replaceAll('<', ' ').trim() : '';
    final givenNames = nameParts.length > 1 ? nameParts[1].replaceAll('<', ' ').trim() : '';

    final isValid = docNumValid && birthValid && expiryValid;

    return MrzResult(
      format: MrzFormat.td1,
      documentType: docType,
      issuingCountry: country,
      documentNumber: docNum,
      isDocumentNumberValid: docNumValid,
      nationality: nationality,
      birthDate: birthDate,
      isBirthDateValid: birthValid,
      sex: sex,
      expiryDate: expiryDate,
      isExpiryDateValid: expiryValid,
      surname: surname,
      givenNames: givenNames,
      isValid: isValid,
    );
  }
}
