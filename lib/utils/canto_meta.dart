// Canto metadata: name, symbol emoji, chapter count, and short description
const List<Map<String, dynamic>> cantoMeta = [
  {
    'number': 1,
    'name': 'Creation',
    'nameHi': 'सृष्टि',
    'nameGu': 'સૃષ્ટિ',
    'symbol': '🪷',
    'description': 'The Bhagavatam is revealed. Questions of Shaunaka Rshi answered by Suta Gosvami.',
    'chapters': 19,
  },
  {
    'number': 2,
    'name': 'The Cosmic Manifestation',
    'nameHi': 'ब्रह्मांड की अभिव्यक्ति',
    'nameGu': 'બ્રહ્માંડ પ્રગટ',
    'symbol': '🌌',
    'description': 'Cosmic creation, the universal form of the Lord, and liberation through devotion.',
    'chapters': 10,
  },
  {
    'number': 3,
    'name': 'The Status Quo',
    'nameHi': 'यथास्थिति',
    'nameGu': 'યથાસ્થિતિ',
    'symbol': '🐚',
    'description': 'Vidura and Maitreya discuss creation, time, and Kapila\'s teachings.',
    'chapters': 33,
  },
  {
    'number': 4,
    'name': 'The Creation of the Fourth Order',
    'nameHi': 'चतुर्थ सृष्टि',
    'nameGu': 'ચોથી સૃષ્ટિ',
    'symbol': '⚔️',
    'description': 'Daksha\'s sacrifice, the curse on the Moon, and Prthu Maharaja.',
    'chapters': 31,
  },
  {
    'number': 5,
    'name': 'The Creative Impetus',
    'nameHi': 'सृजनात्मक प्रेरणा',
    'nameGu': 'સૃજનાત્મક પ્રેરણા',
    'symbol': '🌍',
    'description': 'Priyavrata\'s rule, Bharata\'s wandering, and the cosmic layout.',
    'chapters': 26,
  },
  {
    'number': 6,
    'name': 'Prescribed Duties for Mankind',
    'nameHi': 'मनुष्य के कर्तव्य',
    'nameGu': 'માનવ ફ૨ज',
    'symbol': '🔱',
    'description': 'Ajamila\'s redemption, Vishvanara, and Daksha\'s new progeny.',
    'chapters': 19,
  },
  {
    'number': 7,
    'name': 'The Science of God',
    'nameHi': 'ईश्वर का विज्ञान',
    'nameGu': 'ઈશ્વ૨નું વિજ્ઞાન',
    'symbol': '🦁',
    'description': 'Prahlada Maharaja and Hiranyakashipu — devotion triumphs over evil.',
    'chapters': 15,
  },
  {
    'number': 8,
    'name': 'Withdrawal of the Cosmic Creations',
    'nameHi': 'ब्रह्मांड का संहार',
    'nameGu': 'બ્રહ્માંડ સ૨ળ',
    'symbol': '🐘',
    'description': 'Gajendra Moksha, the churning of the ocean, and Vamana avatara.',
    'chapters': 24,
  },
  {
    'number': 9,
    'name': 'Liberation',
    'nameHi': 'मुक्ति',
    'nameGu': 'મોક્ષ',
    'symbol': '☀️',
    'description': 'Dynasties of Manu and the pastimes of Rama, Parashurama, and Krishna.',
    'chapters': 24,
  },
  {
    'number': 10,
    'name': 'The Summum Bonum',
    'nameHi': 'परम सत्य',
    'nameGu': '૫૨મ સત્ય',
    'symbol': '🦚',
    'description': 'The pastimes of Lord Krishna — the heart of the Bhagavatam.',
    'chapters': 90,
  },
  {
    'number': 11,
    'name': 'General History',
    'nameHi': 'सामान्य इतिहास',
    'nameGu': 'સામાન્ય ઇતિહાસ',
    'symbol': '🎯',
    'description': 'Final instructions of Krishna to Uddhava and dissolution of the Yadavas.',
    'chapters': 31,
  },
  {
    'number': 12,
    'name': 'The Age of Deterioration',
    'nameHi': 'पतन का युग',
    'nameGu': 'પ‌તનનો યુગ',
    'symbol': '🕉️',
    'description': 'Kaliyuga, the Bhagavata Purana\'s glory, and the conclusion.',
    'chapters': 13,
  },
];

/// Returns the symbol emoji for a given canto number (1-indexed)
String cantoSymbol(int number) {
  if (number < 1 || number > 12) return '🪷';
  return cantoMeta[number - 1]['symbol'] as String;
}

/// Returns the English name for a given canto number
String cantoName(int number) {
  if (number < 1 || number > 12) return 'Canto $number';
  return cantoMeta[number - 1]['name'] as String;
}

/// Returns the description for a given canto number
String cantoDescription(int number) {
  if (number < 1 || number > 12) return '';
  return cantoMeta[number - 1]['description'] as String;
}
