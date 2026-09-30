import Foundation

extension String {
  /// Restores umlauts in text that was written with "ae", "oe" and "ue".
  var restoringUmlauts: String {
    let exceptions: Set<String> = ["oktaeder", "oktaeders", "tetraeder", "tetraeders", "uetliberg"]
    var result = ""
    var word = ""
    func flush() {
      result += exceptions.contains(word.lowercased()) ? word : Self.replaceUmlauts(in: word)
      word = ""
    }
    for character in self {
      if character.isLetter {
        word.append(character)
      } else {
        flush()
        result.append(character)
      }
    }
    flush()
    return result
  }

  /// Replaces "ae", "oe" and "ue" with umlauts. "ue" after a vowel or "q" stays, as in "neue", "grauer" or "Quersumme".
  private static func replaceUmlauts(in word: String) -> String {
    let characters = Array(word)
    let umlauts: [Character: String] = ["a": "ä", "o": "ö", "u": "ü", "A": "Ä", "O": "Ö", "U": "Ü"]
    var output = ""
    var index = 0
    while index < characters.count {
      let current = characters[index]
      let previous = index > 0 ? Character(characters[index - 1].lowercased()) : nil
      let isKeptUE = current == "u" && previous.map { "aeiouq".contains($0) } == true
      if index + 1 < characters.count, characters[index + 1] == "e",
         let umlaut = umlauts[current], !isKeptUE {
        output += umlaut
        index += 2
      } else {
        output.append(current)
        index += 1
      }
    }
    return output
  }
}
