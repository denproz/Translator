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
	
	let inputStack = ClearableTextViewStack()
	let outputStack = TextViewWithAcitivitiesStack()
	
	private func setupConstraints() {
		outputStack.outputTextView.snp.makeConstraints { (make) in
			make.height.equalTo(200)
		}
	}
	
	/// Swaps texts of textviews
	func swapText() {
		(inputStack.inputTextView.text, outputStack.outputTextView.text) = (outputStack.outputTextView.text, inputStack.inputTextView.text)
	}
	
	private func setupViews() {
		addArrangedSubview(inputStack)
		addArrangedSubview(outputStack)
		outputStack.isHidden = true
		axis = .vertical
		spacing = 1
		layer.borderColor = UIColor.systemGray.cgColor
		layer.borderWidth = 0.3
		
		clipsToBounds = true
		layer.cornerRadius = 10
		layer.cornerCurve = .continuous
		layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
	}
}
