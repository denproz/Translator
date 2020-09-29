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
		case .en: return "английский"
		case .it: return "итальянский"
		case .es: return "испанский"
		case .de: return "немецкий"
		case .pt: return "португальский"
		case .ru: return "русский"
		case .fr: return "французский"
		}
	}
}
