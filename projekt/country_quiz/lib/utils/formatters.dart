/// Pomocné funkcie na formátovanie a porovnávanie textu.

/// 49037 -> "49 037"
String formatNumber(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('\u00A0');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.day}. ${d.month}. ${d.year}  ${two(d.hour)}:${two(d.minute)}';
}

const Map<String, String> _regionNames = {
  'Africa': 'Afrika',
  'Americas': 'Amerika',
  'Antarctic': 'Antarktída',
  'Asia': 'Ázia',
  'Europe': 'Európa',
  'Oceania': 'Oceánia',
  'Polar': 'Polárne oblasti',
  'Antarctic Ocean': 'Antarktický oceán',
};

/// Preklad názvu regiónu z API do slovenčiny.
String regionLabel(String region) => _regionNames[region] ?? region;

const String _accented = 'áäčďéěíĺľňóôŕřšťúůýžöüçãõñèàâêî';
const String _plain = 'aacdeeillnoorrstuuyzoucaoneaaei';

/// Odstráni diakritiku a prevedie text na malé písmená
/// (vyhľadávanie "cesko" nájde "Česko", správne abecedné radenie).
String normalize(String input) {
  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (final char in lower.split('')) {
    final index = _accented.indexOf(char);
    buffer.write(index >= 0 ? _plain[index] : char);
  }
  return buffer.toString();
}
