import UIKit
import RxSwift
import SnapKit

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
	
	lazy var fromLanguageButton: UIButton = {
		let button = UIButton()
		button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
		button.titleLabel?.adjustsFontForContentSizeCategory = true
		button.tag = SelectedButton.from.rawValue
		button.contentHorizontalAlignment = .trailing
		return button
	}()
	
	lazy var swapLanguagesButton: UIButton = {
		let button = UIButton()
		let image = UIImage(systemName: "arrow.right.arrow.left")!.withRenderingMode(.alwaysTemplate)
		button.setImage(image, for: .normal)
		button.setImage(image, for: .disabled)
		button.tintColor = .white
		return button
	}()
	
	lazy var toLanguageButton: UIButton = {
		let button = UIButton()
		button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
		button.titleLabel?.adjustsFontForContentSizeCategory = true
		button.tag = SelectedButton.to.rawValue
		button.contentHorizontalAlignment = .leading
		return button
	}()
	
	private func setupViews() {
		addArrangedSubview(fromLanguageButton)
		addArrangedSubview(swapLanguagesButton)
		addArrangedSubview(toLanguageButton)
		
		fromLanguageButton.snp.makeConstraints { make in
			make.height.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.40)
		}
		
		swapLanguagesButton.snp.makeConstraints { make in
			make.height.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.2)
		}
		
		toLanguageButton.snp.makeConstraints { make in
			make.height.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.40)
		}
		
		axis = .horizontal
		distribution = .fill
		backgroundColor = .red
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
