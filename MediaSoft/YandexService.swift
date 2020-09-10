//
//  TranslationService.swift
//  MediaSoft
//
//  Created by Denis Prozukin on 07.09.2020.
//  Copyright © 2020 Denis Prozukin. All rights reserved.
//

import Foundation
import Moya

let API_KEY = "AQVNxTC5ZIJhtrkaP33_VbA02M3ucVLgzFVuyVzM"

enum YandexService {
	case requestTranslation(text: [String], targetLanguageCode: String)
	case detectLanguage(text: String)
}

extension YandexService: TargetType {
	var baseURL: URL {
		return URL(string: "https://translate.api.cloud.yandex.net/translate/v2")!
	}
	
	var path: String {
		switch self {
		case .requestTranslation(_, _):
			return "/translate"
		case .detectLanguage(_):
			return "/detect"
		}
	}
	
	var method: Moya.Method {
		switch self {
		case .requestTranslation(_, _), .detectLanguage(_):
			return .post
		}
	}
	
	var sampleData: Data {
		return Data()
	}
	
	var task: Task {
		switch self {
		case .requestTranslation(let text, let targetLanguageCode):
			return .requestParameters(parameters: ["texts": text, "targetLanguageCode": targetLanguageCode], encoding: JSONEncoding.default)
		case .detectLanguage(let text):
			return .requestParameters(parameters: ["text": text], encoding: JSONEncoding.default)
		}
	}
	
	var headers: [String : String]? {
		return ["Content-Type": "application/json", "Authorization": "Api-Key \(API_KEY)"]
	}
}
