import UIKit

class TextViewsStackView: UIStackView {
	
	private override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
		setupConstraints()
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	let inputTextViewStack = ClearableTextViewStack()
	
	let outputTextView: UITextView = {
		let textView = UITextView()
		textView.backgroundColor = .systemBackground
		textView.isHidden = true
		textView.font = UIFont.preferredFont(forTextStyle: .title3)
		textView.adjustsFontForContentSizeCategory = true
		textView.isScrollEnabled = true
		textView.isEditable = false
		textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 10)
		textView.layer.borderWidth = 0.3
		return textView
	}()
	
	private func setupConstraints() {
		outputTextView.snp.makeConstraints { (make) in
			make.height.equalTo(200)
		}
	}
	
	private func setupViews() {
		addArrangedSubview(inputTextViewStack)
		addArrangedSubview(outputTextView)
		axis = .vertical
		spacing = 0.2
	}
}
