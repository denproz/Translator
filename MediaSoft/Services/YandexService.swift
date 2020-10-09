import Foundation
import Moya

let API_KEY = "AQVNxTC5ZIJhtrkaP33_VbA02M3ucVLgzFVuyVzM"

enum YandexService {
	case requestTranslation(text: [String], sourceLanguageCode: String, targetLanguageCode: String)
}

extension YandexService: TargetType {
	var baseURL: URL {
		return URL(string: "https://translate.api.cloud.yandex.net/translate/v2")!
	}
	
	var path: String {
		switch self {
			case .requestTranslation(_, _, _):
				return "/translate"
		}
	}
	
	var method: Moya.Method {
		switch self {
			case .requestTranslation(_, _, _):
				return .post
		}
	}
	
	var sampleData: Data {
		return Data()
	}
	
	var task: Task {
		switch self {
			case .requestTranslation(let text, let sourceLanguageCode, let targetLanguageCode):
				return .requestParameters(parameters: ["texts": text, "sourceLanguageCode": sourceLanguageCode, "targetLanguageCode": targetLanguageCode], encoding: JSONEncoding.default)
		}
	}
	
	var headers: [String : String]? {
		return ["Content-Type": "application/json", "Authorization": "Api-Key \(API_KEY)"]
	}
}
