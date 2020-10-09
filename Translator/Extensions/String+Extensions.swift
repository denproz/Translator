import Foundation
extension String {
	
	var containsValidCharacter: Bool {
		guard self != "" else { return true }
		let noNeedToRestrict = CharacterSet(charactersIn: " ")
		if noNeedToRestrict.containsUnicodeScalars(of: self.last!) {
			return true
		} else {
			return CharacterSet.letters.containsUnicodeScalars(of: self.last!)
		}
	}
}

extension CharacterSet {
	func containsUnicodeScalars(of character: Character) -> Bool {
		return character.unicodeScalars.allSatisfy(contains(_:))
	}
}
