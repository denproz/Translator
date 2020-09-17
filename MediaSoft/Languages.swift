//
//  Languages.swift
//  MediaSoft
//
//  Created by Denis Prozukin on 14.09.2020.
//  Copyright © 2020 Denis Prozukin. All rights reserved.
//

import Foundation

enum Languages: String, CaseIterable {
	//				case en = "английский"
	//				case it = "итальянский"
	//				case es = "испанский"
	//				case de = "немецкий"
	//				case pt = "португальский"
	//				case ru = "русский"
	//				case fr = "французский"
	
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
