import UIKit
import RxSwift

class LanguagesStackView: UIStackView {
	enum SelectedButton: Int {
		case from
		case to
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
		roundCorners(corners: [.topLeft, .topRight], radius: 10)
	}
	
	convenience init(fromLanguage: Languages, toLanguage: Languages) {
		self.init(frame: .zero)
		fromLanguageButton.setTitle(fromLanguage.languageName, for: .normal)
		toLanguageButton.setTitle(toLanguage.languageName, for: .normal)
		
	}
	
	var onLanguagePressed: ((Int) -> Void)?
	var onSwapPressed: (() -> Void)?
	
	let fromLanguageButton: UIButton = {
		let button = UIButton()
		button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
		button.titleLabel?.adjustsFontSizeToFitWidth = true
		button.tag = SelectedButton.from.rawValue
		button.contentHorizontalAlignment = .trailing
		return button
	}()
	
	let swapLanguagesButton: UIButton = {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
		let image = UIImage(systemName: "arrow.right.arrow.left")!.withRenderingMode(.alwaysTemplate)
		button.setImage(image, for: .normal)
		button.setImage(image, for: .disabled)
		button.tintColor = .white
		return button
	}()
	
	let toLanguageButton: UIButton = {
		let button = UIButton()
		button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
		button.titleLabel?.adjustsFontSizeToFitWidth = true
		button.tag = SelectedButton.to.rawValue
		button.contentHorizontalAlignment = .leading
		return button
	}()
	
	private func setupViews() {
		addArrangedSubview(fromLanguageButton)
		addArrangedSubview(swapLanguagesButton)
		addArrangedSubview(toLanguageButton)
		axis = .horizontal
		distribution = .fillEqually
		backgroundColor = .red
		
		layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
		isLayoutMarginsRelativeArrangement = true
	}
	
	private func addActions() {
		fromLanguageButton.addTarget(self, action: #selector(languageButtonTapped(_:)), for: .touchUpInside)
		swapLanguagesButton.addTarget(self, action: #selector(swapButtonTapped(_:)), for: .touchUpInside)
		toLanguageButton.addTarget(self, action: #selector(languageButtonTapped(_:)), for: .touchUpInside)
	}
	
	@objc private func languageButtonTapped(_ sender: UIButton) {
		onLanguagePressed?(sender.tag)
	}
	
	@objc private func swapButtonTapped(_ sender: UIButton) {
		sender.debounce()
		onSwapPressed?()
	}
}
