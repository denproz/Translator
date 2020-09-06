//
//  ViewController.swift
//  MediaSoft
//
//  Created by Denis Prozukin on 04.09.2020.
//  Copyright © 2020 Denis Prozukin. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import RxSwift
import RxCocoa

class ViewController: UIViewController {
	let inputTextView: UITextView = {
		let textView = UITextView()
		textView.text = "Введите текст"
		textView.font = UIFont.preferredFont(forTextStyle: .body)
		textView.adjustsFontForContentSizeCategory = true
		textView.textColor = .lightGray
		textView.backgroundColor = .systemBackground
		textView.isScrollEnabled = true
		return textView
	}()
	
	let outputTextView: UITextView = {
		let textView = UITextView()
		textView.backgroundColor = .systemBackground
		textView.isHidden = true
		textView.font = UIFont.preferredFont(forTextStyle: .body)
		textView.adjustsFontForContentSizeCategory = true
		textView.isUserInteractionEnabled = false
		return textView
	}()
	
	let collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		
		return collectionView
	}()
	
	let disposeBag = DisposeBag()
	
	var stackView: UIStackView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let titleImage = UIImage(named: "hyyandex")
		let titleImageView = UIImageView(image: titleImage)
		titleImageView.contentMode = .scaleAspectFit
		navigationItem.titleView = titleImageView
		
		navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "#FFCC00")
		collectionView.backgroundColor = hexStringToUIColor(hex: "#FFCC00")
		
		hideKeyboardWhenTappedAround()
		configureStackView()
		
		view.backgroundColor = .systemGray
		
		inputTextView.delegate = self
		outputTextView.delegate = self
		
	}
	
	func hexStringToUIColor (hex:String) -> UIColor {
		var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		
		if (cString.hasPrefix("#")) {
			cString.remove(at: cString.startIndex)
		}
		
		if ((cString.count) != 6) {
			return UIColor.gray
		}
		
		var rgbValue:UInt64 = 0
		Scanner(string: cString).scanHexInt64(&rgbValue)
		
		return UIColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
}

extension ViewController {
	func configureStackView() {
		stackView = UIStackView(arrangedSubviews: [inputTextView, outputTextView])
		stackView.axis = .vertical
		stackView.spacing = 1
		
		view.addSubview(stackView)
		
		inputTextView.snp.makeConstraints { (make) in
			make.height.equalTo(120)
		}
		
		outputTextView.snp.makeConstraints { (make) in
			make.height.equalTo(120)
		}
		
		stackView.snp.makeConstraints { (make) in
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
		}
		inputTextView.layoutIfNeeded()
		
		view.addSubview(collectionView)
		collectionView.snp.makeConstraints { (make) in
			make.top.equalTo(stackView.snp.bottom).offset(8)
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.bottom.equalToSuperview()
		}
	}
}

extension ViewController: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == UIColor.lightGray {
			textView.text = nil
			textView.textColor = UIColor.black
		}
	}
	
	func textViewDidChange(_ textView: UITextView) {
		if textView == inputTextView {
			if textView.hasText {
				UIView.animate(withDuration: 0.2) {
					self.outputTextView.isHidden = false
				}
			} else {
				UIView.animate(withDuration: 0.15) {
					self.outputTextView.isHidden = true
				}
			}
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView == inputTextView && textView.text.isEmpty {
			textView.text = "Введите текст"
			textView.textColor = UIColor.lightGray
		} else {
			let headers: HTTPHeaders = ["Content-Type": "application/json", "Authorization": "Api-Key AQVNxTC5ZIJhtrkaP33_VbA02M3ucVLgzFVuyVzM"]
			let parameters: [String: Any] = ["texts": [textView.text], "targetLanguageCode": "ru"]
			AF.request("https://translate.api.cloud.yandex.net/translate/v2/translate", method: .post, parameters: parameters, encoding: JSONEncoding.default ,headers: headers).responseJSON { (response) in
				switch response.result {
				case .success(let data):
					let data = try! JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
					let decoder = JSONDecoder()
					let translation = try! decoder.decode(Translations.self, from: data)
					self.outputTextView.text = translation.translations[0].text
				case .failure(let error):
					print(error.errorDescription)
				}
			}
		}
		
		
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if range.location == 0 && text == "\n" {
			return false
		}
		if outputTextView.isHidden == true {
			outputTextView.text = nil
		}
		return true
	}
	
	
}

