//
//  UIViewController+Extensions.swift
//  MediaSoft
//
//  Created by Denis Prozukin on 06.09.2020.
//  Copyright © 2020 Denis Prozukin. All rights reserved.
//

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
}
