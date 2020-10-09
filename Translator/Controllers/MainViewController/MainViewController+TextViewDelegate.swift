import UIKit

extension MainViewController: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == UIColor.lightGray {
			textView.text = nil
			textView.textColor = UIColor.black
		}
	}
	
	func textViewDidChange(_ textView: UITextView) {
		if textView == textviewsStack.inputStack.inputTextView {
			if textView.text.count >= 1 {
				UIView.animate(withDuration: 0.2) {
					self.textviewsStack.inputStack.addArrangedSubview(self.textviewsStack.inputStack.clearButton)
					self.textviewsStack.outputStack.isHidden = false
					self.textviewsStack.inputStack.clearButton.isHidden = false
				}
			} else if textView.text.count == 0 {
				UIView.animate(withDuration: 0.15) {
					self.textviewsStack.outputStack.isHidden = true
					self.textviewsStack.outputStack.outputTextView.text = nil
					self.textviewsStack.inputStack.clearButton.isHidden = true
					self.textviewsStack.inputStack.clearButton.isEnabled = false
				} completion: { (_) in
					self.textviewsStack.inputStack.removeArrangedSubview(self.textviewsStack.inputStack.clearButton)
				}
			}
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView == textviewsStack.inputStack.inputTextView && textView.text.isEmpty {
			textView.text = "Введите текст"
			textView.textColor = UIColor.lightGray
		}
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if (range.location == 0 && text == " ") {
			return false
		}
		
		if let character = text.first, character.isNewline {
			textView.resignFirstResponder()
			return false
		}
		
		if textviewsStack.outputStack.outputTextView.isHidden == true {
			self.textviewsStack.outputStack.outputTextView.text = nil
		}
		return true
	}
}
