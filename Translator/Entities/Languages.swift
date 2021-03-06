import UIKit
/// List of all supported languages, their indexes, names and corresponding flag images
enum Languages: String, CaseIterable, Codable {
	case en
	case it
	case es
	case de
	case pt
	case ru
	case fr
	
	var index: Int {
		switch self {
			case .en: return 0
			case .it: return 1
			case .es: return 2
			case .de: return 3
			case .pt: return 4
			case .ru: return 5
			case .fr: return 6
		}
	}
	
	var languageName: String {
		switch self {
			case .en: return "Английский"
			case .it: return "Итальянский"
			case .es: return "Испанский"
			case .de: return "Немецкий"
			case .pt: return "Португальский"
			case .ru: return "Русский"
			case .fr: return "Французский"
		}
	}
	
	var nativeLanguageName: String {
		switch self {
			case .en: return "English"
			case .it: return "Italiano"
			case .es: return "Español"
			case .de: return "Deutsch"
			case .pt: return "Português"
			case .ru: return "Русский"
			case .fr: return "Français"
		}
	}
	
	var image: UIImage {
		switch self {
			case .en: return UIImage(named: "enFlag")!
			case .it: return UIImage(named: "itFlag")!
			case .es: return UIImage(named: "esFlag")!
			case .de: return UIImage(named: "deFlag")!
			case .pt: return UIImage(named: "ptFlag")!
			case .ru: return UIImage(named: "ruFlag")!
			case .fr: return UIImage(named: "frFlag")!
		}
	}
	
}
