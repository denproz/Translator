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
	let outputTextViewStack = TextViewWithAcitivitiesStack()
	
	private func setupConstraints() {
		outputTextViewStack.outputTextView.snp.makeConstraints { (make) in
			make.height.equalTo(200)
		}
	}
	
	private func setupViews() {
		addArrangedSubview(inputTextViewStack)
		addArrangedSubview(outputTextViewStack)
		outputTextViewStack.isHidden = true
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
