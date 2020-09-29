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
	
	func incrementID() -> Int{
		let realm = try! Realm()
		if let retNext = realm.objects(TranslationModel.self).sorted(byKeyPath: "id").first?.id {
			return retNext + 1
		} else {
			return 1
		}
	}
	
//	private enum CodingKeys: String, CodingKey {
//		case inputText, outputText, fromLanguage, toLanguage
//	}
	
//	init(inputText: String, outputText: String, fromLanguage: String, toLanguage: String) {
//		self.inputText = inputText
//		self.outputText = outputText
//		self.fromLanguage = fromLanguage
//		self.toLanguage = toLanguage
//	}
	
//	static func == (lhs: TranslationModel, rhs: TranslationModel) -> Bool {
//		lhs.id == rhs.id
//	}
}
