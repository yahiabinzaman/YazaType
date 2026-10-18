import Foundation

/// Fast, high-accuracy Bengali Unicode to ANSI (Bijoy / SutonnyMJ) Converter Engine
public class UnicodeToBijoy {

    private static let conversionMap: [(from: String, to: String)] = [
        // Complex Conjuncts (3-char & 4-char sequences first)
        ("ক"+"্"+"ষ"+"্"+"ম", "\u{00B2}"),
        ("ক"+"্"+"ষ"+"্"+"ণ", "\u{00B6}\u{00E8}"),
        ("ক"+"্"+"ষ"+"্"+"ব", "\u{00B6}\u{00A1}"),
        ("স"+"্"+"ত"+"্"+"র", "\u{00AF}\u{00BF}"),
        ("স"+"্"+"ত"+"্"+"ব", "\u{00AF}\u{2014}\u{00A1}"),
        ("ন"+"্"+"ত"+"্"+"র", "\u{0161}\u{00BF}"),
        ("ন"+"্"+"ত"+"্"+"ব", "\u{0161}\u{2014}\u{00A1}"),
        ("ম"+"্"+"ভ"+"্"+"র", "\u{00A4}\u{00A3}"),
        ("স"+"্"+"ক"+"্"+"র", "\u{00AF}\u{0152}"),
        ("ষ"+"্"+"ক"+"্"+"র", "\u{00AE}\u{0152}"),

        // 2-char Conjuncts
        ("ক"+"্"+"ক", "\u{00B0}"),
        ("ক"+"্"+"ট", "\u{00B1}"),
        ("ক"+"্"+"ত", "\u{00B3}"),
        ("ক"+"্"+"ব", "K\u{00A1}"),
        ("ক"+"্"+"ম", "\u{00B4}"),
        ("ক"+"্"+"ষ", "\u{00B6}"),
        ("ক"+"্"+"স", "\u{00B7}"),
        ("ক"+"্"+"ন", "K\u{00E8}"),
        ("ক"+"্"+"ল", "K\u{00AC}"),

        ("খ"+"্"+"ব", "L\u{00A1}"),

        ("গ"+"্"+"দ", "\u{00BA}"),
        ("গ"+"্"+"ধ", "\u{00BB}"),
        ("গ"+"্"+"ন", "M\u{0153}"),
        ("গ"+"্"+"ব", "M\u{00A6}"),
        ("গ"+"্"+"ম", "M\u{00A5}"),
        ("গ"+"্"+"ল", "M\u{00AD}"),
        ("গ"+"ু", "\u{00B8}"),

        ("ঘ"+"্"+"ন", "N\u{0153}"),
        ("ঘ"+"্"+"ব", "N\u{00A1}"),

        ("ঙ"+"্"+"ক", "\u{00BC}"),
        ("ঙ"+"্"+"খ", "\u{2022}L"),
        ("ঙ"+"্"+"গ", "\u{00BD}"),
        ("ঙ"+"্"+"ঘ", "\u{2022}N"),
        ("ঙ"+"্"+"ম", "\u{2022}g"),

        ("চ"+"্"+"চ", "\u{201D}P"),
        ("চ"+"্"+"ছ", "\u{201D}Q"),
        ("চ"+"্"+"ঞ", "\u{201D}T"),
        ("ছ"+"্"+"ব", "Q\u{00A1}"),

        ("জ"+"্"+"জ", "\u{00BE}"),
        ("জ"+"্"+"ঝ", "\u{00C0}"),
        ("জ"+"্"+"ঞ", "\u{00C1}"),
        ("জ"+"্"+"ব", "R\u{00A1}"),

        ("ঞ"+"্"+"চ", "\u{00C2}"),
        ("ঞ"+"্"+"ছ", "\u{00C3}"),
        ("ঞ"+"্"+"জ", "\u{00C4}"),
        ("ঞ"+"্"+"ঝ", "\u{00C5}"),

        ("ট"+"্"+"ট", "\u{00C6}"),
        ("ট"+"্"+"ব", "U\u{00A1}"),
        ("ট"+"্"+"ম", "U\u{00A5}"),

        ("ড"+"্"+"ড", "\u{00C7}"),

        ("ণ"+"্"+"ট", "\u{00C8}"),
        ("ণ"+"্"+"ঠ", "\u{00C9}"),
        ("ণ"+"্"+"ড", "\u{00CA}"),
        ("ণ"+"্"+"ঢ", "\u{2212}"),
        ("ণ"+"্"+"ণ", "Y\u{0153}"),
        ("ণ"+"্"+"ম", "Y\u{00A5}"),
        ("ণ"+"্"+"ব", "Y^"),

        ("ত"+"্"+"ত", "\u{00CB}"),
        ("ত"+"্"+"থ", "\u{00CC}"),
        ("ত"+"্"+"ন", "Z\u{0153}"),
        ("ত"+"্"+"ম", "\u{00CD}"),
        ("ত"+"্"+"ব", "Z\u{00A1}"),
        ("ত"+"্"+"ল", "Z\u{00AC}"),

        ("থ"+"্"+"ব", "_\u{00A1}"),
        ("থ"+"্"+"ল", "_\u{00AD}"),

        ("দ"+"্"+"গ", "\u{02DC}M"),
        ("দ"+"্"+"ঘ", "\u{02DC}N"),
        ("দ"+"্"+"দ", "\u{00CF}"),
        ("দ"+"্"+"ধ", "\u{00D7}"),
        ("দ"+"্"+"ন", "`\u{0153}"),
        ("দ"+"্"+"ব", "\u{00D8}"),
        ("দ"+"্"+"ভ", "\u{2122}\u{00A2}"),
        ("দ"+"্"+"ম", "\u{00D9}"),

        ("ধ"+"্"+"ন", "a\u{0153}"),
        ("ধ"+"্"+"ব", "a\u{0178}"),
        ("ধ"+"্"+"ম", "a\u{00A5}"),

        ("ন"+"্"+"ট", "\u{203A}U"),
        ("ন"+"্"+"ঠ", "\u{00DA}"),
        ("ন"+"্"+"ড", "\u{00DB}"),
        ("ন"+"্"+"ত", "\u{0161}\u{2014}"),
        ("ন"+"্"+"থ", "\u{0161}\u{2019}"),
        ("ন"+"্"+"দ", "\u{203A}`"),
        ("ন"+"্"+"ধ", "\u{00DC}"),
        ("ন"+"্"+"ন", "b\u{0153}"),
        ("ন"+"্"+"ব", "\u{0161}^"),
        ("ন"+"্"+"ম", "b\u{00A5}"),
        ("ন"+"্"+"স", "\u{00DD}"),

        ("প"+"্"+"ট", "\u{00DE}"),
        ("প"+"্"+"ত", "\u{00DF}"),
        ("প"+"্"+"ন", "c\u{0153}"),
        ("প"+"্"+"প", "\u{00E0}"),
        ("প"+"্"+"ম", "c\u{00A5}"),
        ("প"+"্"+"ল", "c\u{00AD}"),
        ("প"+"্"+"স", "\u{00E1}"),

        ("ফ"+"্"+"ল", "d\u{00AC}"),

        ("ব"+"্"+"জ", "\u{00E2}"),
        ("ব"+"্"+"দ", "\u{00E3}"),
        ("ব"+"্"+"ধ", "\u{00E4}"),
        ("ব"+"্"+"ব", "e\u{0178}"),
        ("ব"+"্"+"ল", "e\u{00AD}"),

        ("ভ"+"্"+"ল", "f\u{00AC}"),
        ("ভ"+"্"+"র", "\u{00E5}"),

        ("ম"+"্"+"ন", "\u{00E6}"),
        ("ম"+"্"+"প", "\u{00A4}\u{00FA}"),
        ("ম"+"্"+"ফ", "\u{00E7}"),
        ("ম"+"্"+"ব", "\u{00A4}^"),
        ("ম"+"্"+"ভ", "\u{00A4}\u{00A2}"),
        ("ম"+"্"+"ম", "\u{00A4}\u{00A7}"),
        ("ম"+"্"+"ল", "\u{00A4}\u{00AC}"),

        ("ল"+"্"+"ক", "\u{00E9}"),
        ("ল"+"্"+"গ", "\u{00EA}"),
        ("ল"+"্"+"ট", "\u{00EB}"),
        ("ল"+"্"+"ড", "\u{00EC}"),
        ("ল"+"্"+"প", "\u{00ED}"),
        ("ল"+"্"+"ফ", "\u{00EE}"),
        ("ল"+"্"+"ব", "j\u{00A6}"),
        ("ল"+"্"+"ম", "j\u{00A5}"),
        ("ল"+"্"+"ল", "j\u{00AD}"),

        ("শ"+"্"+"চ", "\u{00F0}"),
        ("শ"+"্"+"ছ", "\u{00F1}"),
        ("শ"+"্"+"ন", "k\u{0153}"),
        ("শ"+"্"+"ব", "k^"),
        ("শ"+"্"+"ম", "k\u{00A5}"),
        ("শ"+"্"+"ল", "k\u{00AD}"),
        ("শ"+"ু", "\u{00EF}"),

        ("ষ"+"্"+"ক", "\u{00AE}\u{2039}"),
        ("ষ"+"্"+"ট", "\u{00F3}"),
        ("ষ"+"্"+"ঠ", "\u{00F4}"),
        ("ষ"+"্"+"ণ", "\u{00F2}"),
        ("ষ"+"্"+"প", "\u{00AE}\u{00FA}"),
        ("ষ"+"্"+"ফ", "\u{00F5}"),
        ("ষ"+"্"+"ম", "\u{00AE}\u{00A7}"),

        ("স"+"্"+"ক", "\u{00AF}\u{2039}"),
        ("স"+"্"+"খ", "\u{00F6}"),
        ("স"+"্"+"ট", "\u{00F7}"),
        ("স"+"্"+"ত", "\u{00AF}\u{2014}"),
        ("স"+"্"+"থ", "\u{00AF}\u{2019}"),
        ("স"+"্"+"প", "\u{00AF}\u{00FA}"),
        ("স"+"্"+"ফ", "\u{00F9}"),
        ("স"+"্"+"ব", "\u{00AF}^"),
        ("স"+"্"+"ম", "\u{00AF}\u{00A7}"),
        ("স"+"্"+"ল", "\u{00AF}\u{00AC}"),

        ("হ"+"্"+"ণ", "n\u{00E8}"),
        ("হ"+"্"+"ন", "\u{00FD}"),
        ("হ"+"্"+"ব", "n\u{0178}"),
        ("হ"+"্"+"ম", "\u{00FE}"),
        ("হ"+"্"+"ল", "n\u{00AC}"),
        ("হ"+"ু", "\u{00FB}"),
        ("হ"+"ৃ", "\u{00FC}"),
        ("র"+"ু", "i\u{00E6}"),
        ("র"+"ূ", "i\u{0192}"),

        // Special Kar & Phal
        ("্"+"য", "\u{00A8}"),
        ("্"+"র", "\u{00AA}"),

        // Nukta & Decomposed Consonants
        ("য"+"়", "q"),
        ("ড"+"়", "o"),
        ("ঢ"+"়", "p"),
        ("ত"+"্"+"\u{200D}", "r"),

        // Single Consonants
        ("ক", "K"), ("খ", "L"), ("গ", "M"), ("ঘ", "N"), ("ঙ", "O"),
        ("চ", "P"), ("ছ", "Q"), ("জ", "R"), ("ঝ", "S"), ("ঞ", "T"),
        ("ট", "U"), ("ঠ", "V"), ("ড", "W"), ("ঢ", "X"), ("ণ", "Y"),
        ("ত", "Z"), ("থ", "_"), ("দ", "`"), ("ধ", "a"), ("ন", "b"),
        ("প", "c"), ("ফ", "d"), ("ব", "e"), ("ভ", "f"), ("ম", "g"),
        ("য", "h"), ("র", "i"), ("ল", "j"), ("শ", "k"), ("ষ", "l"),
        ("স", "m"), ("হ", "n"), ("ড়", "o"), ("ঢ়", "p"), ("য়", "q"),
        ("ৎ", "r"), ("ং", "s"), ("ঃ", "t"), ("ঁ", "u"),
        ("়", ""),

        // Independent Vowels
        ("আ", "Av"), ("অ", "A"), ("ই", "B"), ("ঈ", "C"), ("উ", "D"),
        ("ঊ", "E"), ("ঋ", "F"), ("এ", "G"), ("ঐ", "H"), ("ও", "I"),
        ("ঔ", "J"),

        // Kar Signs (Standalone & Fallbacks)
        ("া", "v"),
        ("ি", "w"),
        ("ী", "x"),
        ("ু", "y"),
        ("ূ", "~"),
        ("ৃ", "\u{2026}"),
        ("ে", "\u{2020}"),
        ("ৈ", "\u{2030}"),
        ("ো", "\u{2020}v"),
        ("ৌ", "\u{2020}\u{0160}"),
        ("ৗ", "\u{0160}"),
        ("্", "&"),
        ("।", "."),
        ("৳", "$"),

        // Digits
        ("০", "0"), ("১", "1"), ("২", "2"), ("৩", "3"), ("৪", "4"),
        ("৫", "5"), ("৬", "6"), ("৭", "7"), ("৮", "8"), ("৯", "9")
    ]

    /// Convert any Bengali Unicode String into SutonnyMJ (ANSI) Keystream
    public static func convert(_ input: String) -> String {
        if input.isEmpty { return input }

        var text = input

        // Step 1: Pre-kar Reordering (E-kar, Oi-kar, Hroshwo-I kar)
        text = reorderPreKars(text)

        // Step 2: Reorder Ref (র্ = র + ্)
        text = reorderRef(text)

        // Step 3: Replace compound and single glyph mappings using literal code-point matching
        for (from, to) in conversionMap {
            text = text.replacingOccurrences(of: from, with: to, options: .literal)
        }

        return text
    }

    /// Reorders Pre-kars (ি, ে, ৈ, ো, ৌ) before the consonant cluster
    private static func reorderPreKars(_ input: String) -> String {
        var chars = Array(input.unicodeScalars).map { String($0) }
        var i = 0

        while i < chars.count {
            let ch = chars[i]

            // Check for pre-kar signs
            if ch == "ি" || ch == "ে" || ch == "ৈ" || ch == "ো" || ch == "ৌ" {
                // Find start of the consonant cluster before this vowel
                var clusterStart = i - 1

                while clusterStart > 0 {
                    if chars[clusterStart - 1] == "্" {
                        clusterStart -= 2
                        if clusterStart < 0 { clusterStart = 0; break }
                    } else {
                        break
                    }
                }

                if clusterStart >= 0 && clusterStart < i {
                    let preKarGlyph: String
                    let postKarGlyph: String?

                    switch ch {
                    case "ি":
                        preKarGlyph = "w"
                        postKarGlyph = nil
                    case "ে":
                        preKarGlyph = "\u{2020}" // †
                        postKarGlyph = nil
                    case "ৈ":
                        preKarGlyph = "\u{2030}" // ‰
                        postKarGlyph = nil
                    case "ো": // E-kar + Aa-kar (v)
                        preKarGlyph = "\u{2020}" // †
                        postKarGlyph = "v"
                    case "ৌ": // E-kar + Ou-kar sign (Š)
                        preKarGlyph = "\u{2020}" // †
                        postKarGlyph = "\u{0160}"
                    default:
                        preKarGlyph = ""
                        postKarGlyph = nil
                    }

                    // Remove the vowel sign from position i
                    chars.remove(at: i)

                    if let post = postKarGlyph {
                        chars.insert(post, at: i)
                    }

                    // Insert the pre-kar glyph before the cluster start
                    chars.insert(preKarGlyph, at: clusterStart)
                    i += 1
                }
            }

            i += 1
        }

        return chars.joined()
    }

    /// Reorders Ref (র্ = র + ্) after the consonant cluster
    private static func reorderRef(_ input: String) -> String {
        var text = input
        let refSeq = "র" + "্"

        while let refRange = text.range(of: refSeq, options: .literal) {
            let afterRef = text[refRange.upperBound...]
            if afterRef.isEmpty { break }

            let charsAfter = Array(afterRef.unicodeScalars).map { String($0) }
            var offset = 0

            // Consume the following consonant and conjunct chain
            if offset < charsAfter.count {
                offset += 1
                while offset + 1 < charsAfter.count && charsAfter[offset] == "্" {
                    offset += 2
                }
            }

            // Also include vowel sign if attached
            if offset < charsAfter.count {
                let nextCh = charsAfter[offset]
                if "ািীুূৃেৈোৌ".contains(nextCh) {
                    offset += 1
                }
            }

            let clusterSub = charsAfter.prefix(offset).joined()
            let refReplacement = clusterSub + "\u{00A9}" // © Ref glyph

            let fullReplaceRange = refRange.lowerBound..<text.index(refRange.upperBound, offsetBy: clusterSub.count)
            text.replaceSubrange(fullReplaceRange, with: refReplacement)
        }

        return text
    }
}
