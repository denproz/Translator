import UIKit

public extension UIControl {
	@objc static var debounceDelay: Double = 0.5
	@objc func debounce(delay: Double = UIControl.debounceDelay, siblings: [UIControl] = []) {
		let buttons = [self] + siblings
		buttons.forEach { $0.isEnabled = false }
		let deadline = DispatchTime.now() + delay
		DispatchQueue.main.asyncAfter(deadline: deadline) {
			buttons.forEach { $0.isEnabled = true }
		}
	}
}
