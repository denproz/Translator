import UIKit
import RxSwift
import RxCocoa
import Moya
import SnapKit
import NaturalLanguage

class ViewController: UIViewController {
	
	enum SelectedButton: Int {
		case from
		case to
	}
	
	var fromLanguage: Languages! = .ru {
		didSet {
			fromLanguageButton.setTitle(fromLanguage.languageName, for: .normal)
		}
	}
	
	var toLanguage: Languages! = .en {
		didSet {
			toLanguageButton.setTitle(toLanguage.languageName, for: .normal)
		}
	}
	// MARK: - Language buttons
	let fromLanguageButton: UIButton = {
		let button = UIButton()
		button.tag = SelectedButton.from.rawValue
		button.contentHorizontalAlignment = .center
		button.addTarget(self, action: #selector(languageButtonTapped(_:)), for: .touchUpInside)
		return button
	}()
	
	let swapLanguagesButton: UIButton = {
		let button = UIButton()
		let image = UIImage(systemName: "arrow.right.arrow.left")!.withRenderingMode(.alwaysTemplate)
		button.setImage(image, for: .normal)
		button.tintColor = .white
		button.addTarget(self, action: #selector(swapButtonTapped), for: .touchUpInside)
		return button
	}()
	
	@objc func swapButtonTapped() {
		self.rotateSwapButton()
		(self.fromLanguage, self.toLanguage) = (self.toLanguage, self.fromLanguage)
		if !self.outputTextView.isHidden {
			(self.inputTextView.text, self.outputTextView.text) = (self.outputTextView.text, self.inputTextView.text)
		}
	}
	
	let toLanguageButton: UIButton = {
		let button = UIButton()
		button.tag = SelectedButton.to.rawValue
		button.addTarget(self, action: #selector(languageButtonTapped(_:)), for: .touchUpInside)
		button.contentHorizontalAlignment = .center
		return button
	}()
	
	@objc func languageButtonTapped(_ sender: UIButton) {
		let vc = LanguageSwitcherViewController()
		vc.delegate = self
		switch sender.tag {
			case SelectedButton.from.rawValue:
				vc.buttonIndex = sender.tag
				navigationController?.present(vc, animated: true, completion: nil)
			case SelectedButton.to.rawValue:
				vc.buttonIndex = sender.tag
				navigationController?.present(vc, animated: true, completion: nil)
			default:
				break
		}
	}
	
	// MARK: - Textfields
	let inputTextView: UITextView = {
		let textView = UITextView()
		textView.text = "Введите текст"
		textView.font = UIFont.preferredFont(forTextStyle: .body)
		textView.adjustsFontForContentSizeCategory = true
		textView.textColor = .lightGray
		textView.backgroundColor = .systemBackground
		textView.isScrollEnabled = true
		textView.layer.borderWidth = 0.3
		textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 20)
		return textView
	}()
	
	let clearButton: UIButton = {
		let button = UIButton()
		let image = UIImage(systemName: "xmark")!.withRenderingMode(.alwaysTemplate)
		button.setImage(image, for: .normal)
		
		button.imageView?.contentMode = .scaleAspectFill
		button.contentHorizontalAlignment = .fill
		button.contentVerticalAlignment = .fill
		
		button.tintColor = .black
		button.isHidden = true
		button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
		return button
	}()
	
	@objc func clearButtonTapped() {
		if !inputTextView.isFirstResponder {
			inputTextView.text = nil
			inputTextView.becomeFirstResponder()
		} else {
			inputTextView.text = ""
		}
		
		UIView.animate(withDuration: 0.15) {
			self.outputTextView.isHidden = true
			self.containerActivitiesView.isHidden = true
		}
		clearButton.isHidden = true
	}
	
	let outputTextView: UITextView = {
		let textView = UITextView()
		textView.backgroundColor = .systemBackground
		textView.isHidden = true
		textView.font = UIFont.preferredFont(forTextStyle: .title3)
		textView.adjustsFontForContentSizeCategory = true
		textView.isScrollEnabled = true
		textView.isEditable = false
		textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 10)
		textView.layer.borderWidth = 0
		return textView
	}()
	
	let shareButton: UIButton = {
		let button = UIButton()
		let image = UIImage(systemName: "square.and.arrow.up")?.withRenderingMode(.alwaysTemplate)
		button.setImage(image, for: .normal)
		button.tintColor = .black
		return button
	}()
	
	let containerActivitiesView: UIView = {
		let view = UIView(frame: .zero)
		view.isHidden = true
		return view
	}()
	
	let collectionView: UICollectionView = {
		let layout = UICollectionViewCompositionalLayout.list(using: UICollectionLayoutListConfiguration(appearance: .plain))
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		return collectionView
	}()
	
	var languageButtonsStackView: UIStackView!
	var stackView: UIStackView!
	let disposeBag = DisposeBag()
	let translationProvider = MoyaProvider<YandexService>()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		fireOffNetwork()
		
		swapLanguagesButton.rx.tap
			.throttle(.milliseconds(500), scheduler: MainScheduler.instance)
			.subscribe(onNext: {
				print("Swap button tapped")
			})
			.disposed(by: disposeBag)
		
		let titleImage = UIImage(named: "hyyandex")
		let titleImageView = UIImageView(image: titleImage)
		titleImageView.contentMode = .scaleAspectFit
		navigationItem.titleView = titleImageView
		
		navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "#FFCC00")
		collectionView.backgroundColor = hexStringToUIColor(hex: "#FFCC00")
		
		configureLanguagesButtonsStackView()
		hideKeyboardWhenTappedAround()
		configureStackView()
		
		view.backgroundColor = .white
		
		inputTextView.delegate = self
		outputTextView.delegate = self
	}
	
	func fireOffNetwork() {
		_ = inputTextView.rx.text.orEmpty
			.debounce(.milliseconds(500), scheduler: MainScheduler.instance)
			.filter { $0.count >= 1 && $0 != "Введите текст" }
			.map { text in
				self.outputTextView.showSpinner()
				let languageRecognizer = NLLanguageRecognizer()
				languageRecognizer.languageConstraints = [.english, .italian, .spanish, .german, .portuguese, .russian, .french]
				languageRecognizer.languageHints = [.english: 0.9, .italian: 0.5, .spanish: 0.7, .german: 0.7, .portuguese: 0.3, .russian: 0.9, .french: 0.7]
				languageRecognizer.processString(text)
				
				let hypotheses = languageRecognizer.languageHypotheses(withMaximum: 1)
				if !hypotheses.keys.contains(NLLanguage(self.fromLanguage.rawValue)) && hypotheses.keys.contains(NLLanguage(self.toLanguage.rawValue)) {
					(self.fromLanguage, self.toLanguage)  = (self.toLanguage, self.fromLanguage)
				} else if !hypotheses.keys.contains(NLLanguage(self.fromLanguage.rawValue)) && !hypotheses.keys.contains(NLLanguage(self.toLanguage.rawValue)) {
					self.fromLanguage = Languages(rawValue: String(hypotheses.keys.first!.rawValue))
				}
				return text
			}
			.flatMapLatest { text -> Single<Response> in
				return self.translationProvider.rx.request(.requestTranslation(text: [text], sourceLanguageCode: self.fromLanguage.rawValue, targetLanguageCode: self.toLanguage.rawValue), callbackQueue: .main)
			}
			.map { response -> String in
				do {
					let translationResponse = try JSONDecoder().decode(TranslationResponse.self, from: response.data)
					let translatedText = translationResponse.items?.first?.text ?? ""
					self.outputTextView.hideSpinner()
					return translatedText
				}
				catch let error {
					print(error.asAFError?.localizedDescription ?? "Error: \(error.localizedDescription)")
					return ""
				}
			}
			.observeOn(MainScheduler.instance)
			.bind(to: outputTextView.rx.text)
			.disposed(by: disposeBag)
	}
	
	
	func rotateSwapButton() {
		UIView.animate(withDuration: 0.3) {
			self.swapLanguagesButton.transform = self.swapLanguagesButton.transform.rotated(by: .pi)
		}
	}
}

extension ViewController {
	func configureLanguagesButtonsStackView() {
		languageButtonsStackView = UIStackView(arrangedSubviews: [fromLanguageButton, swapLanguagesButton, toLanguageButton])
		languageButtonsStackView.axis = .horizontal
		languageButtonsStackView.distribution = .fillEqually
		languageButtonsStackView.backgroundColor = .red
		
		fromLanguageButton.setTitle(fromLanguage.languageName, for: .normal)
		toLanguageButton.setTitle(toLanguage.languageName, for: .normal)
		
		view.addSubview(languageButtonsStackView)
		
		languageButtonsStackView.snp.makeConstraints { (make) in
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
			make.height.equalTo(50)
		}
	}
	
	func configureStackView() {
		stackView = UIStackView(arrangedSubviews: [inputTextView, outputTextView, containerActivitiesView])
		stackView.axis = .vertical
		stackView.spacing = 0.2
		
		containerActivitiesView.addSubview(shareButton)
		view.addSubview(stackView)
		view.addSubview(clearButton)
		view.addSubview(collectionView)
		
		
		inputTextView.snp.makeConstraints { (make) in
			make.height.equalTo(100)
		}
		
		outputTextView.snp.makeConstraints { (make) in
			make.height.equalTo(200)
		}
		
		stackView.snp.makeConstraints { (make) in
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.top.equalTo(languageButtonsStackView.snp.bottom)
		}
		inputTextView.layoutIfNeeded()
		
		clearButton.snp.makeConstraints { (make) in
			make.top.equalTo(languageButtonsStackView.snp.bottom).offset(8)
			make.trailing.equalToSuperview().offset(-8)
			make.height.equalTo(18)
			make.width.equalTo(18)
		}
		
		containerActivitiesView.snp.makeConstraints { (make) in
			make.height.equalTo(50)
		}
		
		shareButton.snp.makeConstraints { (make) in
			make.trailing.equalToSuperview().offset(-8)
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		
		collectionView.snp.makeConstraints { (make) in
			make.top.equalTo(stackView.snp.bottom)
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
			clearButton.isHidden = !textView.hasText
			if textView.text.count >= 1 {
				UIView.animate(withDuration: 0.2) {
					self.outputTextView.isHidden = false
					self.containerActivitiesView.isHidden = false
				}
			} else if textView.text.count == 0 {
				UIView.animate(withDuration: 0.15) {
					self.outputTextView.isHidden = true
					self.containerActivitiesView.isHidden = true
				}
			}
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView == inputTextView && textView.text.isEmpty {
			textView.text = "Введите текст"
			textView.textColor = UIColor.lightGray
		}
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if (range.location == 0 && text == "\n") || (range.location == 0 && text == " ") {
			return false
		}
		if outputTextView.isHidden == true {
			outputTextView.text = nil
		}
		return true
	}
}

extension ViewController: LanguageSwitcherDelegate {
	func swapLanguagesIfMirrored() {
		(fromLanguage, toLanguage) = (toLanguage, fromLanguage)
		if !self.outputTextView.isHidden {
			(self.inputTextView.text, self.outputTextView.text) = (self.outputTextView.text, self.inputTextView.text)
		}
	}
	
	func onLanguageChosen(language: Languages, buttonIndex: Int) {
		inputTextView.becomeFirstResponder()
		switch buttonIndex {
			case SelectedButton.from.rawValue:
				if language != toLanguage {
					fromLanguage = language
				} else {
					swapLanguagesIfMirrored()
				}
			case SelectedButton.to.rawValue:
				if language != fromLanguage {
					toLanguage = language
					let text = inputTextView.text
					inputTextView.text = nil
					inputTextView.text = text
				} else {
					swapLanguagesIfMirrored()
				}
			default:
				break
		}
	}
}



