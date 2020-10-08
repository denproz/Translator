import UIKit
import RxSwift
import Moya
import NaturalLanguage
import Network

extension MainViewController {
	/// Reactive implementation of networking and translation logic
	func executeTranslation() {
		textViewsStackView.inputTextViewStack.inputTextView.rx.text.orEmpty
			.filter { _ in
				return self.isConnectionEstablished
			}
			.debounce(.milliseconds(500), scheduler: MainScheduler.instance)
			.filter { $0.count >= 1 && $0 != "Введите текст" && $0.containsValidCharacter }
			.map { text in
				self.textViewsStackView.outputTextViewStack.pronounceButton.isEnabled = false
				self.textViewsStackView.outputTextViewStack.shareButton.isEnabled = false
				self.textViewsStackView.outputTextViewStack.showSpinner()
				/// Use NLP to get the most predictable result of language detection
				/// Instantiate NlLanguageRecognizer and give it the list of available languages
				/// And their relative probability usages (English and Russian are most likely to be used)
				
					let languageRecognizer = NLLanguageRecognizer()
					languageRecognizer.languageConstraints = [.english, .italian, .spanish, .german, .portuguese, .russian, .french]
					languageRecognizer.languageHints = [.english: 0.9, .italian: 0.5, .spanish: 0.7, .german: 0.7, .portuguese: 0.3, .russian: 0.9, .french: 0.7]
					languageRecognizer.processString(text)
					// Get the most likely language from the input text
					let hypotheses = languageRecognizer.languageHypotheses(withMaximum: 1)
					// If we have Russian-English set and determine that the input text language is our destination language
					// Then just swap languages
					// Otherwise set the destination language to the one detected
					if !hypotheses.keys.contains(NLLanguage(self.fromLanguage.rawValue)) &&
							hypotheses.keys.contains(NLLanguage(self.toLanguage.rawValue)) {
						(self.fromLanguage, self.toLanguage)  = (self.toLanguage, self.fromLanguage)
					} else if !hypotheses.keys.contains(NLLanguage(self.fromLanguage.rawValue)) && !hypotheses.keys.contains(NLLanguage(self.toLanguage.rawValue)) {
						self.fromLanguage = Languages(rawValue: String(hypotheses.keys.first!.rawValue))
					}
					
				return text
			}
			.flatMapLatest { text -> Single<Response> in
				return self.translationProvider.rx.request(.requestTranslation(text: [text], sourceLanguageCode: self.fromLanguage.rawValue, targetLanguageCode: self.toLanguage.rawValue), callbackQueue: .main)
			}
			.map { response -> String in
				do {
					let translationResponse = try JSONDecoder().decode(TranslationResponse.self, from: response.data)
					let translatedText = translationResponse.items?.first?.text ?? ""
					
					self.textViewsStackView.outputTextViewStack.hideSpinner()
					self.textViewsStackView.outputTextViewStack.pronounceButton.isEnabled = true
					self.textViewsStackView.outputTextViewStack.shareButton.isEnabled = true
					self.textViewsStackView.inputTextViewStack.clearButton.isEnabled = true
					
					return translatedText
				}
				catch let error {
					print(error.asAFError?.localizedDescription ?? "Error: \(error.localizedDescription)")
					return ""
				}
			}
			.observeOn(MainScheduler.instance)
			.bind(to: textViewsStackView.outputTextViewStack.outputTextView.rx.text)
			.disposed(by: disposeBag)
	}
}
