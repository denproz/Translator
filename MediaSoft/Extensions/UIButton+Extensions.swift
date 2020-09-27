import UIKit

extension UIButton {
	func rotate() {
		UIView.animate(withDuration: 0.3) {
			self.transform = self.transform.rotated(by: .pi)
		}
	}
}
