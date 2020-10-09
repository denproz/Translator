import Foundation
import RealmSwift

class RealmTranslation: Object  {
	@objc dynamic var inputText: String = ""
	@objc dynamic var outputText: String = ""
	@objc dynamic var fromLanguage: String = ""
	@objc dynamic var toLanguage: String = ""
	@objc dynamic var isFavorite: Bool = false
	@objc dynamic var compoundKey = ""
	@objc dynamic var timestamp = Date().timeIntervalSinceReferenceDate
	dynamic var isFavoriteTimestamp = RealmOptional<TimeInterval>()
	
	override static func primaryKey() -> String? {
		return "compoundKey"
	}
	
	func configure(inputText: String, outputText: String, fromLanguage: String, toLanguage: String){
		self.inputText = inputText
		self.outputText = outputText
		self.fromLanguage = fromLanguage
		self.toLanguage = toLanguage
		self.compoundKey = self.inputText + self.outputText
		
	}
	
	/// Sets/resets translation's isFavorite flag
	func toggleFavorite() {
		let realm = try! Realm()
		try! realm.write {
			isFavorite.toggle()
			if isFavorite {
				isFavoriteTimestamp.value = Date().timeIntervalSinceReferenceDate
			}
		}
	}
}
