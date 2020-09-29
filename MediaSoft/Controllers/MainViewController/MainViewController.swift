import UIKit
import RxSwift
import RxCocoa
import Moya
import SnapKit
import NaturalLanguage
import AVFoundation
import RealmSwift

class MainViewController: UIViewController {
	var isSpeakerPressed = false {
		didSet {
			isSpeakerPressed ? self.activitiesStackView.pronounceButton.setImage(UIImage(systemName: "stop.fill"), for: .normal) : self.activitiesStackView.pronounceButton.setImage(UIImage(systemName: "speaker.1.fill"), for: .normal)
		}
	}
	var fromLanguage: Languages! = .ru {
		didSet {
			languagesStackView.fromLanguageButton.setTitle(fromLanguage.languageName, for: .normal)
		}
	}
	
	var toLanguage: Languages! = .en {
		didSet {
			languagesStackView.toLanguageButton.setTitle(toLanguage.languageName, for: .normal)
		}
	}
	
	var translations: Results<TranslationModel>!
	var notificationToken: NotificationToken?
	
	let disposeBag = DisposeBag()
	let translationProvider = MoyaProvider<YandexService>()
	let realmService = RealmService.shared
	
	lazy var languagesStackView: LanguagesStackView = {
		let stack = LanguagesStackView(fromLanguage: fromLanguage, toLanguage: toLanguage)
		return stack
	}()
	
	lazy var textViewsStackView: TextViewsStackView = {
		let stack = TextViewsStackView()
		return stack
	}()
	
	lazy var activitiesStackView: ActivitiesStackView = {
		let stack = ActivitiesStackView()
		return stack
	}()
	
	lazy var synthesizer = AVSpeechSynthesizer()
	
	var dataSource: UICollectionViewDiffableDataSource<Section, TranslationModel>?
	
	let collectionView: UICollectionView = {
		let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		let layout = UICollectionViewCompositionalLayout.list(using: configuration)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .systemGroupedBackground
		return collectionView
	}()
	
	func setupCollectionView() {
		let registration = UICollectionView.CellRegistration<UICollectionViewListCell, TranslationModel> { (cell, indexPath, translation) in
			var content = cell.defaultContentConfiguration()
			
			content.text = translation.outputText
			content.secondaryText = translation.inputText
			
			cell.contentConfiguration = content
		}
		
		dataSource = UICollectionViewDiffableDataSource<Section, TranslationModel>(collectionView: collectionView) { (collectionView, indexPath, translation) in
			collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: translation)
		}
	}
	
	func populate(with translation: Results<TranslationModel>) {
		var snapshot = NSDiffableDataSourceSnapshot<Section, TranslationModel>()
		let array = translation.toArray()
		snapshot.appendSections([.main])
		snapshot.appendItems(array)
		dataSource?.apply(snapshot)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		executeTranslation()
		
		view.addSubview(languagesStackView)
		languagesStackView.snp.makeConstraints { (make) in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.height.equalTo(50)
		}
		
		languagesStackView.onSwapPressed = { [weak self] in
			guard let self = self else { return }
			self.synthesizer.stopSpeaking(at: .immediate)
			self.isSpeakerPressed = false
			self.languagesStackView.swapLanguagesButton.rotate()
			(self.fromLanguage, self.toLanguage) = (self.toLanguage, self.fromLanguage)
			if !self.textViewsStackView.outputTextView.isHidden {
				(self.textViewsStackView.inputTextViewStack.inputTextView.text, self.textViewsStackView.outputTextView.text) = (self.textViewsStackView.outputTextView.text, self.textViewsStackView.inputTextViewStack.inputTextView.text)
			}
		}
		
		languagesStackView.onLanguagePressed = { [weak self] tag in
			guard let self = self else { return }
			let vc = LanguagesViewController()
			vc.delegate = self
			switch tag {
				case self.languagesStackView.fromLanguageButton.tag:
					vc.buttonIndex = tag
					self.navigationController?.present(vc, animated: true, completion: nil)
				case self.languagesStackView.toLanguageButton.tag:
					vc.buttonIndex = tag
					self.navigationController?.present(vc, animated: true, completion: nil)
				default:
					break
			}
		}
		
		languagesStackView.swapLanguagesButton.rx.tap
			.throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
			.subscribe(onNext: {
				print("Swap button tapped")
			})
			.disposed(by: disposeBag)
		
		view.addSubview(textViewsStackView)
		textViewsStackView.snp.makeConstraints { (make) in
			make.top.equalTo(languagesStackView.snp.bottom)
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
		}
		
		textViewsStackView.inputTextViewStack.onClearPressed = { [weak self] in
			guard let self = self else { return }
			
			let translation = TranslationModel()
			translation.id = translation.incrementID()
			translation.inputText = self.textViewsStackView.inputTextViewStack.inputTextView.text
			translation.outputText = self.textViewsStackView.outputTextView.text
			translation.fromLanguage = self.fromLanguage.rawValue
			translation.toLanguage = self.toLanguage.rawValue
			self.realmService.save(translation)
			self.populate(with: self.translations)
			
			self.textViewsStackView.outputTextView.text = nil
			self.synthesizer.stopSpeaking(at: .immediate)
			if !self.textViewsStackView.inputTextViewStack.inputTextView.isFirstResponder {
				self.textViewsStackView.inputTextViewStack.inputTextView.text = nil
				self.textViewsStackView.inputTextViewStack.inputTextView.becomeFirstResponder()
			} else {
				self.textViewsStackView.inputTextViewStack.inputTextView.text = ""
			}
			
			UIView.animate(withDuration: 0.15) {
				self.textViewsStackView.outputTextView.isHidden = true
				self.textViewsStackView.outputTextView.alpha = 0
				self.activitiesStackView.alpha = 0
			} completion: { _ in
				self.activitiesStackView.isHidden = true
			}
			self.textViewsStackView.inputTextViewStack.clearButton.isHidden = true
			self.activitiesStackView.pronounceButton.isEnabled = false
			self.activitiesStackView.shareButton.isEnabled = false
		}
		
		view.addSubview(activitiesStackView)
		activitiesStackView.snp.makeConstraints { (make) in
			make.leading.equalToSuperview().offset(32)
			make.trailing.equalToSuperview().offset(-32)
			make.top.equalTo(textViewsStackView.snp.bottom)
			make.height.equalTo(60)
		}
		
		synthesizer.delegate = self
		
		activitiesStackView.onPronouncePressed = { [weak self] in
			guard let self = self, let text = self.textViewsStackView.outputTextView.text else { return }
			if !self.isSpeakerPressed {
				self.isSpeakerPressed = true
				let utterance = AVSpeechUtterance(string: text)
				utterance.voice = AVSpeechSynthesisVoice(language: self.toLanguage.rawValue)
				self.synthesizer.speak(utterance)
			} else {
				self.isSpeakerPressed = false
				self.synthesizer.stopSpeaking(at: .immediate)
			}
		}
		
		activitiesStackView.onSharePressed = { [weak self] in
			guard let self = self, let text = self.textViewsStackView.outputTextView.text  else { return }
			let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
			self.present(activityController, animated: true)
		}
		
		view.addSubview(collectionView)
		setupCollectionView()
		collectionView.snp.makeConstraints { (make) in
			make.top.equalTo(activitiesStackView.snp.bottom).offset(16)
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		
		translations = realmService.realm.objects(TranslationModel.self)
		populate(with: translations)
		
		// MARK: - Всякая херота
		let titleImage = UIImage(named: "hyyandex")
		let titleImageView = UIImageView(image: titleImage)
		titleImageView.contentMode = .scaleAspectFit
		navigationItem.titleView = titleImageView
		
		navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "#FFCC00")
		collectionView.backgroundColor = hexStringToUIColor(hex: "#FFCC00")
		
		hideKeyboardWhenTappedAround()
		
		view.backgroundColor = hexStringToUIColor(hex: "#FFCC00")
		
		textViewsStackView.inputTextViewStack.inputTextView.delegate = self
		textViewsStackView.outputTextView.delegate = self
	}
}

extension MainViewController {
	enum Section {
		case main
	}
}

extension MainViewController: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == UIColor.lightGray {
			textView.text = nil
			textView.textColor = UIColor.black
		}
	}
	
	func textViewDidChange(_ textView: UITextView) {
		if textView == textViewsStackView.inputTextViewStack.inputTextView {
			textViewsStackView.inputTextViewStack.clearButton.isHidden = !textView.hasText
			if textView.text.count >= 1 {
				UIView.animate(withDuration: 0.2) {
					self.textViewsStackView.outputTextView.isHidden = false
					self.activitiesStackView.alpha = 1
					self.textViewsStackView.outputTextView.alpha = 1
					self.activitiesStackView.isHidden = false
				}
			} else if textView.text.count == 0 {
				self.textViewsStackView.outputTextView.text = nil
				UIView.animate(withDuration: 0.15) {
					self.textViewsStackView.outputTextView.isHidden = true
					self.textViewsStackView.outputTextView.alpha = 0
					self.activitiesStackView.alpha = 0
				} completion: { _ in
					self.activitiesStackView.isHidden = true
				}
			}
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView == textViewsStackView.inputTextViewStack.inputTextView && textView.text.isEmpty {
			textView.text = "Введите текст"
			textView.textColor = UIColor.lightGray
		}
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if (range.location == 0 && text == "\n") || (range.location == 0 && text == " ") {
			return false
		}
		if textViewsStackView.outputTextView.isHidden == true {
			self.textViewsStackView.outputTextView.text = nil
		}
		return true
	}
}

extension MainViewController: LanguagesViewControllerDelegate {
	func swapLanguagesIfMirrored() {
		(fromLanguage, toLanguage) = (toLanguage, fromLanguage)
		if !self.textViewsStackView.outputTextView.isHidden {
			(self.textViewsStackView.inputTextViewStack.inputTextView.text, self.textViewsStackView.outputTextView.text) = (self.textViewsStackView.outputTextView.text, self.textViewsStackView.inputTextViewStack.inputTextView.text)
		}
	}
	
	func onLanguageChosen(language: Languages, buttonIndex: Int) {
		textViewsStackView.inputTextViewStack.inputTextView.becomeFirstResponder()
		switch buttonIndex {
			case languagesStackView.fromLanguageButton.tag:
				if language != toLanguage {
					fromLanguage = language
				} else {
					swapLanguagesIfMirrored()
				}
			case languagesStackView.toLanguageButton.tag:
				if language != fromLanguage {
					toLanguage = language
					let text = textViewsStackView.inputTextViewStack.inputTextView.text
					textViewsStackView.inputTextViewStack.inputTextView.text = nil
					textViewsStackView.inputTextViewStack.inputTextView.text = text
				} else {
					swapLanguagesIfMirrored()
				}
			default:
				break
		}
	}
}

extension MainViewController: AVSpeechSynthesizerDelegate {
	
	func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
		isSpeakerPressed = true
	}
	
	func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
		isSpeakerPressed = false
	}
}


