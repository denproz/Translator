import UIKit

class TextViewWithAcitivitiesStack: UIStackView {
	var isSpeakerPressed = false {
		didSet {
			isSpeakerPressed ? self.pronounceButton.setImage(UIImage(systemName: "speaker.slash"), for: .normal) : self.pronounceButton.setImage(UIImage(systemName: "speaker.wave.1"), for: .normal)
		}
	}
	
	var onSharePressed: (() -> Void)?
	var onPronouncePressed: (() -> Void)?
	
	private override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
		addActions()
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	let outputTextView: UITextView = {
		let textView = UITextView()
		textView.backgroundColor = .systemBackground
		textView.isHidden = false
		textView.font = UIFont.preferredFont(forTextStyle: .title3)
		textView.adjustsFontForContentSizeCategory = true
		textView.isScrollEnabled = true
		textView.isEditable = false
		textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
		textView.layer.borderWidth = 0
		return textView
	}()
	
	let shareButton: UIButton = {
		let button = UIButton()
		let image = UIImage(systemName: "square.and.arrow.up")?.withRenderingMode(.alwaysTemplate)
		button.setImage(image, for: .normal)
		button.tintColor = .black
		button.isEnabled = false
		button.imageView?.contentMode = .scaleAspectFit
		button.contentVerticalAlignment = .fill
		button.contentHorizontalAlignment = .fill
		return button
	}()
	
	let pronounceButton: UIButton = {
		let button = UIButton()
		let image = UIImage(systemName: "speaker.wave.1")?.withRenderingMode(.alwaysTemplate)
		button.setImage(image, for: .normal)
		button.tintColor = .black
		button.isEnabled = false
		button.imageView?.contentMode = .scaleAspectFit
		button.contentVerticalAlignment = .fill
		button.contentHorizontalAlignment = .fill
		return button
	}()
	
	lazy var activityButtonsStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [pronounceButton, shareButton])
		stack.axis = .horizontal
		stack.distribution = .fillEqually
		stack.backgroundColor = .white
		stack.isHidden = false
		stack.layer.borderWidth = 0
		stack.layoutMargins = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
		stack.isLayoutMarginsRelativeArrangement = true
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.heightAnchor.constraint(equalToConstant: 32).isActive = true
		return stack
	}()
	
	private func setupViews() {
		addArrangedSubview(outputTextView)
		addArrangedSubview(activityButtonsStack)
		axis = .vertical
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		activityButtonsStack.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
	}
	
	private func addActions() {
		pronounceButton.addTarget(self, action: #selector(pronounceButtonTapped(_:)), for: .touchUpInside)
		shareButton.addTarget(self, action: #selector(shareButtonTapped(_:)), for: .touchUpInside)
	}
	
	@objc private func pronounceButtonTapped(_ sender: UIButton) {
		onPronouncePressed?()
	}
	
	@objc private func shareButtonTapped(_ sender: UIButton) {
		onSharePressed?()
	}
	
}
