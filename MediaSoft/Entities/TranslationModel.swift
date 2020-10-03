import Foundation
import RealmSwift

class TranslationModel: Object  {
	@objc dynamic var inputText: String = ""
	@objc dynamic var outputText: String = ""
	@objc dynamic var fromLanguage: String = ""
	@objc dynamic var toLanguage: String = ""
	@objc dynamic var isFavorite: Bool = false
	@objc dynamic var id = UUID().uuidString
	@objc dynamic var timestamp = Date().timeIntervalSinceReferenceDate
	
	
	override static func primaryKey() -> String? {
		return "id"
	}
	
	func toggleFavorite() {
		let realm = try! Realm()
		try! realm.write {
			isFavorite.toggle()
		}
	}
}
