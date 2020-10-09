import UIKit

// MARK: - Languages View Controller Delegate
extension MainViewController: LanguagesViewControllerDelegate {
	/// Swaps languages and, optionally, text views texts
	func swapLanguages() {
		(fromLanguage, toLanguage) = (toLanguage, fromLanguage)
		if !textviewsStack.outputStack.outputTextView.isHidden {
			textviewsStack.swapText()
		}
	}
	
	/// Method that is invoked when the user has chosen a languaged from languages header
	/// - Parameters:
	///   - language: Language that the user has chosen
	///   - buttonIndex: Index of the button that was pressed (**from** or **to** button)
	func onLanguageChosen(language: Languages, buttonIndex: Int) {
		textviewsStack.inputStack.inputTextView.becomeFirstResponder()
		switch buttonIndex {
			case languagesStackView.fromLanguageButton.tag:
				if language != toLanguage {
					fromLanguage = language
				} else {
					swapLanguages()
				}
			case languagesStackView.toLanguageButton.tag:
				if language != fromLanguage {
					toLanguage = language
					let text = textviewsStack.inputStack.inputTextView.text
					textviewsStack.inputStack.inputTextView.text = nil
					textviewsStack.inputStack.inputTextView.text = text
				} else {
					swapLanguages()
				}
			default:
				break
		}
		
	}
}
