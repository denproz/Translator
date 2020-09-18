import UIKit
import RxSwift
import RxCocoa
import Moya
import SnapKit

protocol ViewControllerOutput: class {
	func languageButtonChosen(index: Int)
}

class ViewController: UIViewController {
	weak var output: ViewControllerOutput?
	
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
		let image = UIImage(systemName: "arrow.right.arrow.left")?.withRenderingMode(.alwaysTemplate)
		button.setImage(image, for: .normal)
		button.tintColor = .white
		return button
	}()
	
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
		textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 50)
		return textView
	}()
	
	let clearButton: UIButton = {
		let button = UIButton()
		let image = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate)
		button.setImage(image, for: .normal)
		button.tintColor = .black
		button.isHidden = true
		button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
		return button
	}()
	
	@objc func clearButtonTapped() {
		inputTextView.text = ""
		
		UIView.animate(withDuration: 0.15) {
			self.outputTextView.isHidden = true
		}
		clearButton.isHidden = true
		
	}
	
	let outputTextView: UITextView = {
		let textView = UITextView()
		textView.backgroundColor = .systemBackground
		textView.isHidden = true
		textView.font = UIFont.preferredFont(forTextStyle: .body)
		textView.adjustsFontForContentSizeCategory = true
		textView.isUserInteractionEnabled = false
		textView.layer.borderWidth = 0.3
		return textView
	}()
	
	let tableView: UITableView = {
		let tableView = UITableView()
		return tableView
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
			.subscribe(onNext: { [unowned self] _ in
				#warning("пофиксить from кнопку когда меняешь ее на английский и печатаешь по-русски")
				self.rotateSwapButton()
				(self.fromLanguage, self.toLanguage) = (self.toLanguage, self.fromLanguage)
				if !self.outputTextView.isHidden {
					(self.inputTextView.text, self.outputTextView.text) = (self.outputTextView.text, self.inputTextView.text)
				}
			})
			.disposed(by: disposeBag)
		

		let titleImage = UIImage(named: "hyyandex")
		let titleImageView = UIImageView(image: titleImage)
		titleImageView.contentMode = .scaleAspectFit
		navigationItem.titleView = titleImageView
		
		navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "#FFCC00")
		tableView.backgroundColor = hexStringToUIColor(hex: "#FFCC00")
		tableView.separatorStyle = .none
		
		configureLanguagesButtonsStackView()
		hideKeyboardWhenTappedAround()
		configureStackView()
		
		view.backgroundColor = .red
		
		inputTextView.delegate = self
		outputTextView.delegate = self
	}
	
	func fireOffNetwork() {
		let search = inputTextView.rx.text.orEmpty
			.filter { !$0.isEmpty && $0 != "Введите текст" }
			.debug()
			.debounce(.milliseconds(300), scheduler: MainScheduler.instance)
			.flatMapLatest { text in
				self.translationProvider.rx.request(.requestTranslation(text: [text], targetLanguageCode: self.toLanguage.rawValue), callbackQueue: .global(qos: .userInitiated))
			}
			.observeOn(MainScheduler.instance)
		
		search
			.map { response -> String in
				do {
					let translationResponse = try JSONDecoder().decode(TranslationResponse.self, from: response.data)
					let translationText = translationResponse.items?.first?.text ?? ""
					return translationText
				}
				catch let error {
					print(error.asAFError?.localizedDescription ?? "Error: \(error.localizedDescription)")
					return ""
				}
			}
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
		stackView = UIStackView(arrangedSubviews: [inputTextView, outputTextView])
		stackView.axis = .vertical
		stackView.spacing = 0.2
		
		view.addSubview(stackView)
		
		inputTextView.snp.makeConstraints { (make) in
			make.height.equalTo(120)
		}
		
		view.addSubview(clearButton)
		clearButton.snp.makeConstraints { (make) in
			make.top.equalTo(inputTextView.snp.top).offset(8)
			make.trailing.equalTo(inputTextView.snp.trailing).offset(-8)
		}
		
		outputTextView.snp.makeConstraints { (make) in
			make.height.equalTo(120)
		}
		
		stackView.snp.makeConstraints { (make) in
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.top.equalTo(languageButtonsStackView.snp.bottom)
		}
		inputTextView.layoutIfNeeded()
		
		view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) in
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
			if textView.hasText && textView.text.count == 1 {
				UIView.animate(withDuration: 0.2) {
					self.outputTextView.isHidden = false
				}
			} else if !textView.hasText {
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
		}
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if (range.location == 0 && text == "\n") {
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
				fireOffNetwork()
			} else {
				swapLanguagesIfMirrored()
			}
		default:
			break
		}
	}
}



