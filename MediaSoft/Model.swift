//
//  Model.swift
//  MediaSoft
//
//  Created by Denis Prozukin on 06.09.2020.
//  Copyright © 2020 Denis Prozukin. All rights reserved.
//

import Foundation

struct Translations: Decodable {
	let translations: [Translation]
}

struct Translation: Decodable {
	let detectedLanguageCode: String?
	let text: String?
}
