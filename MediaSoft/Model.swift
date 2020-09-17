import Foundation

struct TranslationResponse: Decodable {
	var items: [Translation]?
	
	enum CodingKeys: String, CodingKey {
		case translations
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		items = try container.decode([Translation].self, forKey: .translations)
	}
}

struct Translation: Decodable {
	var detectedLanguage: String?
	var text: String?
	
	enum CodingKeys: String, CodingKey {
		case detectedLanguage = "detectedLanguageCode"
		case text
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		detectedLanguage = try container.decode(String.self, forKey: .detectedLanguage)
		text = try container.decode(String.self, forKey: .text)
	}
}

