//
//  ViewController.swift
//  MediaSoft
//
//  Created by Denis Prozukin on 04.09.2020.
//  Copyright © 2020 Denis Prozukin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Moya

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
	
	let tableView: UITableView = {
		let tableView = UITableView()
		return tableView
	}()
	
	
	var stackView: UIStackView!
	
	let translationProvider = MoyaProvider<YandexService>()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let titleImage = UIImage(named: "hyyandex")
		let titleImageView = UIImageView(image: titleImage)
		titleImageView.contentMode = .scaleAspectFit
		navigationItem.titleView = titleImageView
		
		navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "#FFCC00")
		tableView.backgroundColor = hexStringToUIColor(hex: "#FFCC00")
		
		hideKeyboardWhenTappedAround()
		configureStackView()
		
		view.backgroundColor = .systemGray
		
		inputTextView.delegate = self
		outputTextView.delegate = self
		
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
		
		view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) in
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
			translationProvider.request(.requestTranslation(text: [textView.text], targetLanguageCode: "ru")) { [weak self] (result) in
				guard let self = self else { return }
				switch result {
				case .success(let response):
					let translation = try! JSONDecoder().decode(TranslationResponse.self, from: response.data)
					DispatchQueue.main.async {
						self.outputTextView.text = translation.items?.first?.text
					}
				case .failure(let error):
					print(error.localizedDescription)
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

