import os

with open('/Users/colorlab/Downloads/Illustrator automation/Converter by Yaza/Convert_Bijoy_to_Bornomala_Unicode.jsx', 'r', encoding='utf-8') as f:
    content = f.read()

start_idx = content.find('var Bijoy2UnicodeEngine = (function () {')
end_idx = content.find('})();', start_idx) + 5
engine_code = content[start_idx:end_idx]

unicode_to_ansi = '''
var Unicode2AnsiEngine = (function() {
    var invMapV1 = {
        "০": "0", "১": "1", "২": "2", "৩": "3", "৪": "4",
        "৫": "5", "৬": "6", "৭": "7", "৮": "8", "৯": "9",
        "অ": "A", "আ": "Av", "ই": "B", "ঈ": "C", "উ": "D",
        "ঊ": "E", "ঋ": "F", "এ": "G", "ঐ": "H", "ও": "I", "ঔ": "J",
        "ক": "K", "খ": "L", "গ": "M", "ঘ": "N", "ঙ": "O",
        "চ": "P", "ছ": "Q", "জ": "R", "ঝ": "S", "ঞ": "T",
        "ট": "U", "ঠ": "V", "ড": "W", "ঢ": "X", "ণ": "Y",
        "ত": "Z", "থ": "_", "দ": "`", "ধ": "a", "ন": "b",
        "প": "c", "ফ": "d", "ব": "e", "ভ": "f", "ম": "g",
        "য": "h", "র": "i", "ল": "j", "শ": "k", "ষ": "l",
        "স": "m", "হ": "n", "ড়": "o", "ঢ়": "p", "য়": "q",
        "ৎ": "r", "ং": "s", "ঃ": "t", "ঁ": "u",
        "া": "v", "ি": "w", "ী": "x", "ু": "y", "ূ": "~", "ৃ": "„",
        "ে": "‡", "ৈ": "‰", "ৌ": "Š", "্": "&", "।": "|", "৳": "$",
        "্য": "¨", "\\u09CD\\u09AF": "¨",
        "্র": "ª", "\\u09CD\\u09B0": "ª",
        "স্ব": "¯^", "শ্ব": "k¦", "ত্ব": "Z¡", "দ্ব": "Ø", "ধ্ব": "aŸ",
        "ষ্ব": "®^", "হ্ব": "nŸ", "ব্ব": "eŸ", "ল্ব": "j¦", "গ্ব": "M¦",
        "ঘ্ব": "N¡", "ট্ব": "U¡", "থ্ব": "_¡", "ন্ব": "š^",
        "ক্ষ্ম": "²", "ক্ক": "°", "ক্ট": "±", "ক্ত্ব": "³¡", "ক্ত": "³",
        "ক্ব": "K¡", "স্ক্র": "¯Œ", "ক্র": "µ", "স্ক্ল": "¯‹¬", "ক্ল": "K¬",
        "ক্ন": "Kè", "ক্ম": "´", "ক্ষ্ণ": "¶è", "ক্ষ্ব": "¶¡", "ঙ্ক্ক্ষ": "•¶",
        "ক্ষ": "¶", "ক্স": "·", "খ্ব": "L¡", "গু": "¸", "গ্দ": "º",
        "গ্ধ": "»", "গ্ন": "Mœ", "গ্ম": "M¥", "গ্ল": "M­",
        "ঘ্ন": "Nœ", "ঙ্ক": "¼", "ঙ্ম": "•g", "ঙ্খ": "•L",
        "ঙ্গ": "½", "ঙ্ঘ": "•N", "চ্ছ্ব": "”Q¡", "চ্ছ": "”Q", "চ্চ": "”P",
        "চ্ঞ": "”T", "ছ্ব": "Q¡", "জ্জ্ব": "¾¡", "জ্জ": "¾", "জ্ঝ": "À",
        "জ্ঞ": "Á", "জ্ব": "R¡", "ঞ্চ": "Â", "ঞ্ছ": "Ã", "ঞ্জ": "Ä",
        "ঞ্ঝ": "Å", "ট্ট": "Æ", "ট্ম": "U¥", "ড্ড": "Ç",
        "ণ্ট": "È", "ণ্ঠ": "É", "ণ্ড": "Ê", "ণ্ঢ": "−", "ণ্ণ": "Yœ",
        "ণ্ম": "Y¥", "ন্স": "Ý", "ন্ত্ব": "š—¡", "স্ত্ব": "¯—¡", "ত্ত্ব": "Ë¡",
        "ত্ত": "Ë", "ত্থ": "Ì", "ত্ন": "Zœ", "ত্ম": "Í", "ত্ল": "Z¬",
        "ত্র": "Î", "থ্ল": "_­", "ন্দ্ব": "›Ø",
        "দ্গ": "˜M", "দ্ঘ": "˜N", "দ্দ": "Ï", "দ্ধ": "×",
        "দ্ভ": "™¢", "দ্ম": "Ù", "ধ্ন": "aœ", "ধ্ম": "a¥",
        "ন্ট": "›U", "ন্ঠ": "Ú", "ন্ড": "Û", "ন্ত": "š—", "ন্ত্র": "š¿",
        "ন্থ": "š’", "ন্দ": "›`", "ন্ধ": "Ü", "ন্ন": "bœ",
        "ন্ম": "b¥", "প্ট": "Þ", "প্ত": "ß", "প্ন": "cœ", "প্প": "à",
        "প্ম": "c¥", "প্ল": "c­", "প্স": "á", "ফ্ল": "d¬", "ব্জ": "â",
        "ব্দ": "ã", "ব্ধ": "ä", "ব্ল": "e­", "ভ্র": "å",
        "ভ্ল": "f¬", "ম্ন": "æ", "ম্প": "¤c", "ম্ফ": "ç",
        "ম্ব": "¤^", "ম্ভ": "¤¢", "ম্ভ্র": "¤£", "ম্ম": "¤§", "ম্র": "¤ª",
        "ম্ল": "¤­", "ল্ক": "é", "ল্গ": "ê", "ল্ট": "ë", "ল্ড": "ì",
        "ল্প": "í", "ল্ফ": "î", "ল্ম": "j¥", "ল্ল": "j­",
        "শু": "ï", "শ্চ": "ð", "শ্ছ": "ñ", "শ্ন": "kœ",
        "শ্ম": "k¥", "শ্ল": "k­", "ষ্ক": "®‹", "ষ্ক্র": "®Œ", "ষ্ট": "ó",
        "ষ্ঠ": "ô", "ষ্ণ": "ò", "ষ্প": "®c", "স্ফ": "ù", "ষ্ম": "®§",
        "ষ্র": "®ª", "স্ক": "¯‹", "স্ট": "÷", "স্খ": "ö", "স্তু": "¯‘",
        "স্ত": "¯—", "স্ত্র": "¯¿", "স্থ": "¯’", "স্ন": "¯œ", "স্প": "¯c",
        "স্ম": "¯§", "স্র": "¯ª", "স্ল": "¯­",
        "হু": "û", "হৃ": "ü", "হ্ন": "ý", "হ্ম": "þ", "হ্ল": "n¬", "হ্ণ": "nè",
        "রু": "iy", "রূ": "iƒ", "প্র": "cÖ", "গ্র": "MÖ", "ব্র": "eÖ", "ফ্র": "dÖ", "শ্র": "kÖ", "ধ্র": "aª", "ন্র": "bª"
    };

    var invMapV2 = Object.assign({}, invMapV1, {
        "ক্ষ": "ÿ", "ক্ষ্ব": "ÿ¡", "ক্ষ্ণ": "ÿè", "ঙ্ক্ক্ষ": "•ÿ",
        "গ্ল": "Mø", "প্ল": "cø", "ব্ল": "eø", "ম্ল": "¤ø", "ল্ল": "jø",
        "শ্ল": "kø", "স্ল": "¯ø", "থ্ল": "_ø", "জ্ঞ": "Á",
        "ন্ত": "šÍ", "স্ত": "¯Í", "ন্ত্ব": "šÍ¡", "স্ত্ব": "¯Í¡", "ত্ম": "Z¥"
    });

    var invMapV3 = Object.assign({}, invMapV1, {
        "ক": "„", "খ": "…", "গ": "†", "ঘ": "‡", "ঙ": "ˆ",
        "চ": "‰", "ছ": "Š", "জ": "‹", "ঝ": "G", "ঞ": "~Œ",
        "ট": "Ý", "ঠ": "à", "ড": "v", "ঢ": "‘", "ত": "“",
        "থ": "í", "দ": "”", "ধ": "•", "ন": "˜", "প": "þ™",
        "ফ": "š", "ব": "î", "ভ": "¦", "ম": "›", "য": "ë",
        "র": "îû", "ল": "œ", "শ": "Ÿ", "ষ": "¡ì", "হ": "£",
        "ড়": "vþü", "ঢ়": "‘þü", "য়": "ëû", "ৎ": "ê",
        "া": "y", "ি": "!", "ী": "#", "ু": "%", "ূ": ")", "ৃ": ",",
        "ে": "ö", "ৈ": "÷", "ৌ": "ö...ï", "্": "ä", "।": "Ð"
    });

    function sortKeys(obj) {
        var keys = Object.keys(obj);
        keys.sort(function(a, b) { return b.length - a.length; });
        return keys;
    }

    var keysV1 = sortKeys(invMapV1);
    var keysV2 = sortKeys(invMapV2);
    var keysV3 = sortKeys(invMapV3);

    function preProcessV1(text) {
        var s = text;
        s = s.replace(/([\u0985-\u09B9\u09DC-\u09DF](?:\u09CD[\u0985-\u09B9\u09DC-\u09DF])*)\u09CB/g, "‡$1v");
        s = s.replace(/([\u0985-\u09B9\u09DC-\u09DF](?:\u09CD[\u0985-\u09B9\u09DC-\u09DF])*)\u09CC/g, "‡$1Š");
        s = s.replace(/\u09B0\u09CD([\u0985-\u09B9\u09DC-\u09DF](?:\u09CD[\u0985-\u09B9\u09DC-\u09DF])*(?:[\u09BE-\u09CC\u09D7])?)/g, "$1©");
        s = s.replace(/([\u0985-\u09B9\u09DC-\u09DF](?:\u09CD[\u0985-\u09B9\u09DC-\u09DF])*)\u09BF/g, "w$1");
        s = s.replace(/([\u0985-\u09B9\u09DC-\u09DF](?:\u09CD[\u0985-\u09B9\u09DC-\u09DF])*)\u09C7/g, "‡$1");
        s = s.replace(/([\u0985-\u09B9\u09DC-\u09DF](?:\u09CD[\u0985-\u09B9\u09DC-\u09DF])*)\u09C8/g, "‰$1");
        return s;
    }

    function toAnsi(text, mapObj, keys, preProcessFn) {
        if (!text) return "";
        var s = preProcessFn ? preProcessFn(text) : text;
        for (var i = 0; i < keys.length; i++) {
            var k = keys[i];
            if (s.indexOf(k) !== -1) {
                s = s.split(k).join(mapObj[k]);
            }
        }
        return s;
    }

    return {
        toAnsiV1: function(text) { return toAnsi(text, invMapV1, keysV1, preProcessV1); },
        toAnsiV2: function(text) { return toAnsi(text, invMapV2, keysV2, preProcessV1); },
        toAnsiV3: function(text) { return toAnsi(text, invMapV3, keysV3, preProcessV1); }
    };
})();
'''

full_script = f'''/**
 * Converter by Yaza — Web Engine
 * Developer: Yahia Bin Zaman
 * High-Precision Bi-directional Unicode <-> ANSI (V1, V2, V3) Converter
 */

{engine_code}

{unicode_to_ansi}

window.YazaConverter = {{
    ansiToUnicode: function(text, version) {{
        if (!text) return '';
        if (version === 'v2') return Bijoy2UnicodeEngine.convertV2(text);
        if (version === 'v3') return Bijoy2UnicodeEngine.convertV3(text);
        return Bijoy2UnicodeEngine.convertV1(text);
    }},
    unicodeToAnsi: function(text, version) {{
        if (!text) return '';
        if (version === 'v2') return Unicode2AnsiEngine.toAnsiV2(text);
        if (version === 'v3') return Unicode2AnsiEngine.toAnsiV3(text);
        return Unicode2AnsiEngine.toAnsiV1(text);
    }}
}};
'''

with open('/Users/colorlab/Downloads/borno/docs/converter-engine.js', 'w', encoding='utf-8') as f:
    f.write(full_script)

print('Updated docs/converter-engine.js successfully!')
