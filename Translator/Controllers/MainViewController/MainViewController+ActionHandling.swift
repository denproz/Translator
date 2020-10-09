import UIKit
import AVFoundation

extension MainViewController {
	func handleActions() {
		languagesStackView.onSwapPressed = { [weak self] in
			guard let self = self else { return }
			self.synthesizer.stopSpeaking(at: .immediate)
			self.textviewsStack.outputStack.isSpeakerPressed = false
			self.languagesStackView.swapLanguagesButton.rotate()
			(self.fromLanguage, self.toLanguage) = (self.toLanguage, self.fromLanguage)
			
			if !self.textviewsStack.outputStack.isHidden {
				(self.textviewsStack.inputStack.inputTextView.text, self.textviewsStack.outputStack.outputTextView.text) = (self.textviewsStack.outputStack.outputTextView.text, self.textviewsStack.inputStack.inputTextView.text)
			}
		}
		
		languagesStackView.onLanguagePressed = { [weak self] tag in
			guard let self = self else { return }
			let vc = LanguagesViewController()
			vc.delegate = self
			switch tag {
				case self.languagesStackView.fromLanguageButton.tag:
					vc.buttonIndex = tag
					vc.selectedlanguageRow = self.fromLanguage.index
					self.navigationController?.present(vc, animated: true, completion: nil)
				case self.languagesStackView.toLanguageButton.tag:
					vc.buttonIndex = tag
					vc.selectedlanguageRow = self.toLanguage.index
					self.navigationController?.present(vc, animated: true, completion: nil)
				default:
					break
			}
		}
		
		textviewsStack.inputStack.onClearTapped = { [weak self] in
			guard let self = self else { return }
			
			let translation = RealmTranslation()
			translation.configure(inputText: self.textviewsStack.inputStack.inputTextView.text,
														outputText: self.textviewsStack.outputStack.outputTextView.text,
														fromLanguage: self.fromLanguage.rawValue,
														toLanguage: self.toLanguage.rawValue)
			
			let existingTranslation = self.realmService.realm.object(ofType: RealmTranslation.self, forPrimaryKey: translation.compoundKey)
			if existingTranslation == nil {
				self.realmService.save(translation)
				self.populate(with: self.translations)
			}
			
			self.synthesizer.stopSpeaking(at: .immediate)
			
			if !self.textviewsStack.inputStack.inputTextView.isFirstResponder {
				self.textviewsStack.inputStack.inputTextView.text = nil
				self.textviewsStack.inputStack.inputTextView.becomeFirstResponder()
			} else {
				self.textviewsStack.inputStack.inputTextView.text = nil
			}
			
			UIView.animate(withDuration: 0.15) {
				self.textviewsStack.outputStack.isHidden = true
				self.textviewsStack.outputStack.outputTextView.text = nil
				self.textviewsStack.inputStack.clearButton.isHidden = true
			} completion: { (_) in
				self.textviewsStack.inputStack.removeArrangedSubview(self.textviewsStack.inputStack.clearButton)
			}
			
			self.textviewsStack.inputStack.clearButton.isEnabled = false
			
		}
		
		
		textviewsStack.outputStack.onPronouncePressed = { [weak self] in
			guard let self = self, let text = self.textviewsStack.outputStack.outputTextView.text else { return }
			if !self.textviewsStack.outputStack.isSpeakerPressed {
				self.textviewsStack.outputStack.isSpeakerPressed = true
				let utterance = AVSpeechUtterance(string: text)
				utterance.voice = AVSpeechSynthesisVoice(language: self.toLanguage.rawValue)
				self.synthesizer.speak(utterance)
			} else {
				self.textviewsStack.outputStack.isSpeakerPressed = false
				self.synthesizer.stopSpeaking(at: .immediate)
			}
		}
		
		textviewsStack.outputStack.onSharePressed = { [weak self] in
			guard let self = self, let text = self.textviewsStack.outputStack.outputTextView.text  else { return }
			let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
			self.present(activityController, animated: true)
		}
	}
}
