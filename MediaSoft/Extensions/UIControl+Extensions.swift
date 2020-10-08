import UIKit

public extension UIControl {
	@objc static var debounceDelay: Double = 0.4
	@objc func debounce(delay: Double = UIControl.debounceDelay) {
		let buttons = [self]
		buttons.forEach { $0.isEnabled = false }
		let deadline = DispatchTime.now() + delay
		DispatchQueue.main.asyncAfter(deadline: deadline) {
			buttons.forEach { $0.isEnabled = true }
		}
	}
}
