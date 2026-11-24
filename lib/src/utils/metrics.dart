import 'dart:math';

class OcrMetrics {
  /// Calculates Levenshtein edit distance between two strings.
  static int levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = s1[i] == s2[j] ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[s2.length];
  }

  /// Character Error Rate: CER = (Substitutions + Deletions + Insertions) / Total Reference Characters
  static double calculateCer(String reference, String hypothesis) {
    if (reference.isEmpty) return hypothesis.isEmpty ? 0.0 : 1.0;
    final distance = levenshteinDistance(reference, hypothesis);
    return distance / reference.length;
  }

  /// Word Error Rate: WER
  static double calculateWer(String reference, String hypothesis) {
    final refWords = reference.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final hypWords = hypothesis.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    if (refWords.isEmpty) return hypWords.isEmpty ? 0.0 : 1.0;

    final n = refWords.length;
    final m = hypWords.length;
    List<List<int>> d = List.generate(n + 1, (_) => List.filled(m + 1, 0));

    for (int i = 0; i <= n; i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= m; j++) {
      d[0][j] = j;
    }

    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        int cost = refWords[i - 1] == hypWords[j - 1] ? 0 : 1;
        d[i][j] = min(d[i - 1][j] + 1, min(d[i][j - 1] + 1, d[i - 1][j - 1] + cost));
      }
    }

    return d[n][m] / n;
  }

  /// Exact Match metric (1.0 if identical, 0.0 otherwise).
  static double calculateExactMatch(String reference, String hypothesis) {
    return reference.trim() == hypothesis.trim() ? 1.0 : 0.0;
  }
}
