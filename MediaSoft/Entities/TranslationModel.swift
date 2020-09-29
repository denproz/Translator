import Foundation
import RealmSwift

class TranslationModel: Object  {
	@objc dynamic var inputText: String = ""
	@objc dynamic var outputText: String = ""
	@objc dynamic var fromLanguage: String = ""
	@objc dynamic var toLanguage: String = ""
	@objc dynamic var id = 0
	
	override static func primaryKey() -> String? {
		return "id"
	}
	
	func incrementID() -> Int {
		let realm = try! Realm()
		return (realm.objects(TranslationModel.self).max(ofProperty: "id") as Int? ?? 0) + 1
	}
}
