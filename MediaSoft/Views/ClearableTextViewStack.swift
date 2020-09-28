//
//  ClearableTextViewStack.swift
//  MediaSoft
//
//  Created by Denis Prozukin on 27.09.2020.
//  Copyright © 2020 Denis Prozukin. All rights reserved.
//

import UIKit

class ClearableTextViewStack: UIStackView {
	
	private override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
		setupConstraints()
		addActions()
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var onClearPressed: (() -> Void)?
	
	let inputTextView: UITextView = {
		let textView = UITextView()
		textView.text = "Введите текст"
		textView.font = UIFont.preferredFont(forTextStyle: .body)
		textView.adjustsFontForContentSizeCategory = true
		textView.textColor = .lightGray
		textView.backgroundColor = .systemBackground
		textView.isScrollEnabled = true
		textView.layer.borderWidth = 0
		return textView
	}()
	
	let clearButton: UIButton = {
		let button = UIButton()
		let image = UIImage(systemName: "xmark")!.withRenderingMode(.alwaysTemplate)
		button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 4)
		button.setImage(image, for: .normal)
		
		button.imageView?.contentMode = .scaleAspectFit
		button.contentHorizontalAlignment = .fill
		button.contentVerticalAlignment = .fill
		
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: 28).isActive = true
		button.widthAnchor.constraint(equalToConstant: 28).isActive = true
		button.tintColor = .red
		button.isHidden = true
		button.backgroundColor = .white

		return button
	}()
	
	private func setupViews() {
		backgroundColor = .white
		addArrangedSubview(inputTextView)
		addArrangedSubview(clearButton)
		axis = .horizontal
		alignment = .top
		distribution = .fill
//		layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//		isLayoutMarginsRelativeArrangement = true
	}
	
	private func setupConstraints() {
		inputTextView.snp.makeConstraints { (make) in
			make.height.equalTo(150)
		}
	}
	
	private func addActions() {
		clearButton.addTarget(self, action: #selector(clearButtonPressed(_:)), for: .touchUpInside)
	}
	
	@objc private func clearButtonPressed(_ sender: UIButton) {
		onClearPressed?()
	}

}
