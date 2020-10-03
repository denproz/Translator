import UIKit

class ActivitiesStackView: UIStackView {
	var isSpeakerPressed = false {
		didSet {
			isSpeakerPressed ? self.pronounceButton.setImage(UIImage(systemName: "stop.fill"), for: .normal) : self.pronounceButton.setImage(UIImage(systemName: "speaker.1.fill"), for: .normal)
		}
	}
	
	private override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
		addActions()
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
	}
	
	var onSharePressed: (() -> Void)?
	var onPronouncePressed: (() -> Void)?
    
	let shareButton: UIButton = {
		let button = UIButton()
		let image = UIImage(systemName: "square.and.arrow.up")?.withRenderingMode(.alwaysTemplate)
		button.setImage(image, for: .normal)
		button.tintColor = .white
		button.isEnabled = false
		button.imageView?.contentMode = .scaleAspectFit
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: 22).isActive = true
		return button
	}()
	
	let pronounceButton: UIButton = {
		let button = UIButton()
		let image = UIImage(systemName: "speaker.1.fill")?.withRenderingMode(.alwaysTemplate)
		button.setImage(image, for: .normal)
		button.tintColor = .white
		button.isEnabled = false
		button.imageView?.contentMode = .scaleAspectFit
		button.heightAnchor.constraint(equalToConstant: 22).isActive = true
		return button
	}()
	
	private func setupViews() {
		addArrangedSubview(pronounceButton)
		addArrangedSubview(shareButton)
		axis = .horizontal
		distribution = .fillEqually
		alignment = .center
		backgroundColor = .red
		isHidden = true
		alpha = 0
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
