import Foundation

enum Languages: String, CaseIterable, Codable {
	case en
	case it
	case es
	case de
	case pt
	case ru
	case fr
	
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
}
