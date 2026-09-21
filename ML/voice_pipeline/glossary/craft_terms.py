"""
Craft Vocabulary Glossary.

Curated Indian handicraft terminology injected into transcription prompts.

General speech models learn from news and broadcast audio, where these words
barely appear, so they get substituted with the nearest common word — "Dhokra"
becomes "doctor", "Chikankari" becomes "chicken curry". Since these terms are
often the product name itself, that failure is expensive.

Passing the vocabulary as a prompt hint measurably reduces the substitution.
"""

from __future__ import annotations


# ── Craft Categories ─────────────────────────────────────────────────────────

CATEGORIES: list[str] = [
    "Pottery",
    "Textiles",
    "Woodwork",
    "Jewelry",
    "Paintings",
    "Bamboo Craft",
    "Brass",
    "Leather",
    "Stone Carving",
    "Metalwork",
]


# ── Craft Terms by Domain ────────────────────────────────────────────────────

TEXTILE_TERMS: list[str] = [
    "Bandhani", "Ajrakh", "Chikankari", "Kalamkari", "Ikat", "Patola",
    "Banarasi", "Chanderi", "Kanjeevaram", "Phulkari", "Kantha", "Sujani",
    "Block print", "Batik", "Zari", "Zardozi", "Pashmina", "Khadi",
    "Handloom", "Tussar", "Muga", "Eri silk",
]

POTTERY_TERMS: list[str] = [
    "Terracotta", "Blue pottery", "Khurja pottery", "Black pottery",
    "Chaak", "Kulhad", "Surahi", "Matka", "Diya", "Glazed earthenware",
]

METAL_TERMS: list[str] = [
    "Dhokra", "Bidriware", "Bell metal", "Brassware", "Thewa",
    "Meenakari", "Filigree", "Kansa", "Repousse",
]

PAINTING_TERMS: list[str] = [
    "Madhubani", "Mithila", "Pattachitra", "Warli", "Gond", "Kalighat",
    "Phad", "Kerala mural", "Tanjore", "Miniature painting", "Cheriyal",
]

WOOD_BAMBOO_TERMS: list[str] = [
    "Channapatna", "Sandalwood carving", "Rosewood inlay", "Sheesham",
    "Bamboo weave", "Cane craft", "Sikki grass", "Screwpine", "Jute craft",
]

MATERIAL_TERMS: list[str] = [
    "Natural dye", "Vegetable dye", "Indigo", "Lac", "Clay", "Riverbed clay",
    "Handspun", "Hand-block printed", "Hand-carved", "Wheel-thrown",
]


# ── Devanagari Terms ─────────────────────────────────────────────────────────

# A Hindi transcript comes back in Devanagari, so Latin-script hints cannot
# match it. These are the same craft vocabulary written the way the recogniser
# will actually output it — without them, "चाक" (potter's wheel) is transcribed
# as "चात".

DEVANAGARI_TERMS: list[str] = [
    # Materials
    "मिट्टी", "टेराकोटा", "पीतल", "कांसा", "चांदी", "लकड़ी", "बांस",
    "जूट", "चमड़ा", "रेशम", "सूती", "ऊन", "पत्थर", "संगमरमर",
    # Techniques
    "चाक", "हस्तनिर्मित", "कढ़ाई", "बुनाई", "नक्काशी", "छपाई",
    "रंगाई", "ढलाई", "जड़ाई", "हथकरघा",
    # Craft names
    "बंधनी", "अजरख", "चिकनकारी", "कलमकारी", "मधुबनी", "वारली",
    "पट्टचित्र", "फुलकारी", "कांथा", "ढोकरा", "मीनाकारी", "जरदोजी",
    # Objects
    "फूलदान", "बर्तन", "सुराही", "कुल्हड़", "दीया", "मूर्ति",
    "साड़ी", "दुपट्टा", "शॉल", "चादर", "थाली",
]


# ── Aggregate ────────────────────────────────────────────────────────────────

ALL_TERMS: list[str] = (
    TEXTILE_TERMS
    + POTTERY_TERMS
    + METAL_TERMS
    + PAINTING_TERMS
    + WOOD_BAMBOO_TERMS
    + MATERIAL_TERMS
)

# ── Regional Script Terms (South Indian & Devanagari) ─────────────────────────

TAMIL_TERMS: list[str] = [
    "மண்", "சுடுமண்", "டெரகோட்டா", "பித்தளை", "வெண்கலம்", "மரம்",
    "பட்டு", "பருத்தி", "கல்", "சந்தன மரம்",
    "கைத்தறி", "நெசவு", "தறி", "கைவினை", "மரச்சிற்பம்", "வடிவமைப்பு", "நூல்",
    "காஞ்சிபுரம் பட்டு", "தஞ்சாவூர் ஓவியம்", "நாச்சியார்கோவில் விளக்கு",
    "சுவாமிமலை வெண்கல சிலை", "பத்தமடை பாய்", "செட்டிநாடு கொட்டான்",
    "மண் பானை", "சுடுமண் சிற்பம்", "புடவை", "மாலை", "விளக்கு",
    "வணக்கம்", "கைவினைஞர்", "தயாரிப்பு", "விற்பனை", "விலை",
]

TELUGU_TERMS: list[str] = [
    "మట్టి", "టెర్రకోట", "ఇత్తడి", "కంచు", "చెక్క", "కలప",
    "పట్టు", "నూలు", "రాయి",
    "చేనేత", "మగ్గం", "హస్తకళ", "చెక్కడాలు", "రంగులు", "అల్లిక",
    "ధర్మవరం పట్టు", "పోచంపల్లి ఇక్కత్", "కలంకారి", "కొండపల్లి బొమ్మలు",
    "ఏటికొప్పాక బొమ్మలు", "బిద్రివేర్", "నిర్మల్ చిత్రాలు", "గాజులు",
    "చీర", "శిల్పం", "కుండ", "దీపం",
    "నమస్కారం", "కళాకారుడు", "ఉత్పత్తి", "అమ్మకం", "ధర",
]

KANNADA_TERMS: list[str] = [
    "ಮಣ್ಣು", "ಟೆರ್ರಾಕೋಟಾ", "ಹಿತ್ತಾಳೆ", "ಕಂಚು", "ಮರ", "ಶ್ರೀಗಂಧ",
    "ರೇಷ್ಮೆ", "ಹತ್ತಿ", "ಕಲ್ಲು",
    "ಕೈಮಗ್ಗ", "ನೇಯ್ಗೆ", "ಕರಕುಶಲ", "ಕೆತ್ತನೆ", "ಬಣ್ಣ", "ವಿನ್ಯಾಸ",
    "ಮೈಸೂರು ರೇಷ್ಮೆ", "ಇಳಕಲ್ ಸೀರೆ", "ಚನ್ನಪಟ್ಟಣ ಗೊಂಬೆ", "ಗಂಧದ ಕೆತ್ತನೆ",
    "ಬಿದ್ರಿ ಕಲೆ", "ಕಿನ್ಹಾಳ ಕಲೆ", "ಮೊಳಕಾಲ್ಮುರು",
    "ಸೀರೆ", "ಮಡಕೆ", "ದೀಪ", "ವಿಗ್ರಹ",
    "ನಮಸ್ಕಾರ", "ಕುಶಲಕರ್ಮಿ", "ಉತ್ಪನ್ನ", "ಮಾರಾಟ", "ಬೆಲೆ",
]

MALAYALAM_TERMS: list[str] = [
    "മണ്ണ്", "ടെറാക്കോട്ട", "പിച്ചള", "വെങ്കലം", "ഓട്", "തടി",
    "പട്ട്", "പരുത്തി", "കയർ", "ചിരട്ട",
    "കൈത്തറി", "നെയ്ത്ത്", "കരകൗശലം", "കൊത്തുപണി", "ചായം",
    "കസവ് സാരി", "ആറന്മുള കണ്ണാടി", "കേരള ചുമർചിത്രം", "നെറ്റിപ്പട്ടം",
    "ചിരട്ട ശില്പം", "കയർ ഉൽപ്പന്നങ്ങൾ", "മര വള്ളം",
    "സാരി", "വിളക്ക്", "പ്രതിമ", "പാത്രം",
    "നമസ്കാരം", "കരകൗശലത്തൊഴിലാളി", "ഉൽപ്പന്നം", "വില്പന", "വില",
]

# Map language codes to their native script craft terms
REGIONAL_SCRIPT_MAP: dict[str, list[str]] = {
    "hi": DEVANAGARI_TERMS,
    "mr": DEVANAGARI_TERMS,
    "ta": TAMIL_TERMS,
    "te": TELUGU_TERMS,
    "kn": KANNADA_TERMS,
    "ml": MALAYALAM_TERMS,
}

# Languages whose transcripts come back in Devanagari script
DEVANAGARI_LANGUAGES: frozenset[str] = frozenset({"hi", "mr"})


def get_glossary_terms(
    category: str | None = None,
    limit: int = 40,
    language_code: str | None = None,
) -> list[str]:
    """
    Return craft terms to inject into a transcription prompt.

    Args:
        category: Optional category hint. When supplied, terms from the matching
                  domain are returned first so the most relevant vocabulary
                  survives the limit.
        limit: Maximum number of terms to return.
        language_code: Source language code ('hi', 'ta', 'te', 'kn', 'ml', 'en', etc.).
                       Script-matched terms for the spoken language are placed first
                       so Whisper's recognition bias operates in the matching script.

    Returns:
        List of craft terms, most relevant first.
    """
    domain_map = {
        "textiles": TEXTILE_TERMS,
        "pottery": POTTERY_TERMS,
        "brass": METAL_TERMS,
        "metalwork": METAL_TERMS,
        "jewelry": METAL_TERMS,
        "paintings": PAINTING_TERMS,
        "woodwork": WOOD_BAMBOO_TERMS,
        "bamboo craft": WOOD_BAMBOO_TERMS,
    }

    norm_lang = (language_code or "").lower().strip()
    script_terms = REGIONAL_SCRIPT_MAP.get(norm_lang, [])

    if category:
        preferred = domain_map.get(category.strip().lower(), [])
        remaining = [t for t in ALL_TERMS if t not in preferred]
        if script_terms:
            ordered = script_terms + preferred + MATERIAL_TERMS + remaining
        elif norm_lang in ["auto", "detect", "none", ""]:
            ordered = preferred + DEVANAGARI_TERMS + TAMIL_TERMS[:10] + TELUGU_TERMS[:10] + MATERIAL_TERMS + remaining
        else:
            ordered = preferred + MATERIAL_TERMS + remaining
    else:
        if script_terms:
            ordered = script_terms + list(ALL_TERMS)
        elif norm_lang in ["auto", "detect", "none", ""]:
            conversational_terms = ["नमस्ते", "कलासेतु", "उत्पाद", "नया सामान", "कैटलॉग", "बिक्री", "कमाई"]
            ordered = conversational_terms + DEVANAGARI_TERMS + TAMIL_TERMS[:10] + TELUGU_TERMS[:10] + list(ALL_TERMS)
        else:
            ordered = list(ALL_TERMS)

    # Preserve order while removing duplicates
    seen: set[str] = set()
    unique = [t for t in ordered if not (t in seen or seen.add(t))]
    return unique[:limit]


def build_prompt_hint(
    category: str | None = None,
    limit: int = 40,
    language_code: str | None = None,
) -> str:
    """
    Format the glossary for a transcription prompt.

    Whisper treats the prompt as *context* — text resembling what it is about
    to hear — not as an instruction. A plain list of expected words biases
    recognition; an English sentence wrapped around them dilutes it. Measured
    on a Hindi sample, the bare list recovered "चाक" where the wrapped version
    did not.
    """
    terms = get_glossary_terms(
        category=category, limit=limit, language_code=language_code
    )
    return ", ".join(terms)
