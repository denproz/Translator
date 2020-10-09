import UIKit
import AVFoundation

extension MainViewController: AVSpeechSynthesizerDelegate {
	func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
		textviewsStack.outputStack.isSpeakerPressed  = true
	}
	
	func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
		textviewsStack.outputStack.isSpeakerPressed  = false
	}
}
