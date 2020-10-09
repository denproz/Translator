import UIKit

extension UIView {
	func roundCorners(corners: UIRectCorner, radius: CGFloat) {
		let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		layer.mask = mask
		layer.cornerCurve = .continuous
	}
}

fileprivate var activityView: UIView?
extension UIView {
	func showSpinner() {
		activityView = UIView(frame: self.bounds)
		activityView?.backgroundColor = .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.2)
		
		let activityIndicator = UIActivityIndicatorView(style: .medium)
		activityIndicator.center = activityView!.center
		activityIndicator.startAnimating()
		activityView!.addSubview(activityIndicator)
		addSubview(activityView!)
		
		Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false) { (_) in
			self.hideSpinner()
		}
	}
	
	func hideSpinner() {
		activityView?.removeFromSuperview()
		activityView = nil
	}
}
