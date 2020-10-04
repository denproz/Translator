import UIKit

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
			case .en: return UIImage(named: "enFlag") ?? UIImage()
			case .it: return UIImage(named: "itFlag") ?? UIImage()
			case .es: return UIImage(named: "esFlag") ?? UIImage()
			case .de: return UIImage(named: "deFlag") ?? UIImage()
			case .pt: return UIImage(named: "ptFlag") ?? UIImage()
			case .ru: return UIImage(named: "ruFlag") ?? UIImage()
			case .fr: return UIImage(named: "frFlag") ?? UIImage()
		}
	}
	
}
