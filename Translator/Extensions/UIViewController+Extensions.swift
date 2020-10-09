import UIKit

extension UIViewController {
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	func hexStringToUIColor(hex:String) -> UIColor {
		var colorString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		
		if colorString.hasPrefix("#") {
			colorString.remove(at: colorString.startIndex)
		}
		
		if colorString.count != 6 {
			return UIColor.white
		}
		
		var rgbValue: UInt64 = 0
		Scanner(string: colorString).scanHexInt64(&rgbValue)
		
		return UIColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
	
	func configureNavigationBar(title: String? = nil, preferredLargeTitle: Bool = true, isNavBarHidden: Bool = false) {
		if #available(iOS 13.0, *) {
			let navBarAppearance = UINavigationBarAppearance()
			navBarAppearance.configureWithTransparentBackground()
			
			navigationController?.navigationBar.standardAppearance = navBarAppearance
			navigationController?.navigationBar.compactAppearance = navBarAppearance
			navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
			
			navigationController?.navigationBar.prefersLargeTitles = preferredLargeTitle
			navigationController?.navigationBar.isTranslucent = true
			navigationController?.navigationBar.isHidden = isNavBarHidden
			navigationItem.title = title
			
		} else {
			navigationController?.navigationBar.isTranslucent = true
			navigationItem.title = title
		}
	}
	
	func configureTabBarItem(title: String, unselectedName: String, selectedName: String) {
		let unselectedImage = UIImage(systemName: unselectedName)
		let selectedImage = UIImage(systemName: selectedName)
		let tbItem = UITabBarItem(title: nil, image: unselectedImage, selectedImage: selectedImage)
		tbItem.title = title
		tabBarItem = tbItem
	}
}

