import UIKit
import RxSwift
import RxCocoa
import Moya
import SnapKit
import NaturalLanguage
import AVFoundation
import RealmSwift

class MainViewController: UIViewController, TappableStar {
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
		stack.inputTextViewStack.inputTextView.delegate = self
		stack.outputTextViewStack.outputTextView.delegate = self
		return stack
	}()
	
	lazy var synthesizer: AVSpeechSynthesizer = {
		let synthesizer = AVSpeechSynthesizer()
		synthesizer.delegate = self
		return synthesizer
	}()
	
	var dataSource: UICollectionViewDiffableDataSource<Section, TranslationModel>!
	
	lazy var collectionView: UICollectionView = {
		var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		
		configuration.backgroundColor = .systemGray5
		
		configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
			guard let self = self else { return nil }
			
			let delete = UIContextualAction(style: .destructive, title: nil, handler: { _, _, completion in
					guard let itemToDelete = self.dataSource?.itemIdentifier(for: indexPath) else {
						completion(false)
						return
					}
					self.remove(itemToDelete)
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						if itemToDelete.isInvalidated {
							completion(false)
							return
						}
						self.realmService.delete(itemToDelete)
					}
					completion(true)
				}
			)
			delete.image = UIImage(systemName: "trash")
			
			
			let deleteAction = UISwipeActionsConfiguration(
				actions: [delete]
			)
			return deleteAction
		}
		
		let layout = UICollectionViewCompositionalLayout.list(using: configuration)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .systemGray5
		collectionView.keyboardDismissMode = .onDrag
		return collectionView
	}()
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		textViewsStackView.inputTextViewStack.inputTextView.resignFirstResponder()
	}
	
	func setupCollectionView() {
		let registration = UICollectionView.CellRegistration<TranslationListCell, TranslationModel> { (cell, indexPath, translation) in
			cell.tapper = self
			cell.translation = translation
		}
		
		dataSource = UICollectionViewDiffableDataSource<Section, TranslationModel>(collectionView: collectionView) { (collectionView, indexPath, translation) in
			let cell = collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: translation)
			cell.toggleFavorite()
			return cell
		}
	}
	
	func onStarTapped(_ cell: TranslationListCell) {
		guard let indexPathTapped = collectionView.indexPath(for: cell),
					let translation = dataSource.itemIdentifier(for: indexPathTapped) else { return }
		translation.toggleFavorite()
		cell.toggleFavorite()
	}
	
	func populate(with translation: Results<TranslationModel>) {
		var snapshot = NSDiffableDataSourceSnapshot<Section, TranslationModel>()
		snapshot.appendSections([.main])
		translations.forEach { (translation) in
			snapshot.appendItems([translation])
		}
//		let animated = translations.count <= 1 ? true : false
		dataSource?.apply(snapshot, animatingDifferences: true)
	}
	
	func reload() {
		var snapshot = dataSource.snapshot()
		snapshot.reloadSections([.main])
		snapshot.reloadItems(translations.toArray())
		dataSource.apply(snapshot, animatingDifferences: true)
	}
	
	func remove(_ translation: TranslationModel) {
		var snapshot = dataSource?.snapshot()
		snapshot?.deleteItems([translation])
		dataSource?.apply(snapshot!)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		print(Realm.Configuration.defaultConfiguration.fileURL)
		
		executeTranslation()
		
		view.addSubview(languagesStackView)
		languagesStackView.snp.makeConstraints { (make) in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
			make.leading.equalToSuperview().offset(8)
			make.trailing.equalToSuperview().offset(-8)
			make.height.equalTo(50)
		}
		
		view.addSubview(textViewsStackView)
		textViewsStackView.snp.makeConstraints { (make) in
			make.top.equalTo(languagesStackView.snp.bottom)
			make.leading.equalToSuperview().offset(8)
			make.trailing.equalToSuperview().offset(-8)
		}

		view.addSubview(collectionView)
		setupCollectionView()
		collectionView.snp.makeConstraints { (make) in
//			make.top.equalTo(textViewsStackView.snp.bottom).inset(15)
			make.top.equalTo(textViewsStackView.snp.bottom)
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		collectionView.layoutIfNeeded()
		collectionView.delegate = self
		
		languagesStackView.onSwapPressed = { [weak self] in
			guard let self = self else { return }
//			if !self.textViewsStackView.inputTextViewStack.inputTextView.isFirstResponder {
//				self.textViewsStackView.inputTextViewStack.inputTextView.becomeFirstResponder()
//			}
			self.synthesizer.stopSpeaking(at: .immediate)
//			if self.textViewsStackView.inputTextViewStack.inputTextView.canBecomeFirstResponder {
//				self.view.endEditing(false)
//			}
			self.textViewsStackView.outputTextViewStack.isSpeakerPressed = false
			self.languagesStackView.swapLanguagesButton.rotate()
			(self.fromLanguage, self.toLanguage) = (self.toLanguage, self.fromLanguage)
			if !self.textViewsStackView.outputTextViewStack.isHidden {
				(self.textViewsStackView.inputTextViewStack.inputTextView.text, self.textViewsStackView.outputTextViewStack.outputTextView.text) = (self.textViewsStackView.outputTextViewStack.outputTextView.text, self.textViewsStackView.inputTextViewStack.inputTextView.text)
			}
		}
		
		languagesStackView.onLanguagePressed = { [weak self] tag in
			guard let self = self else { return }
			let vc = LanguagesViewController()
			vc.delegate = self
			switch tag {
				case self.languagesStackView.fromLanguageButton.tag:
					vc.buttonIndex = tag
					vc.selectedlanguageRow = self.fromLanguage.index
					self.navigationController?.present(vc, animated: true, completion: nil)
				case self.languagesStackView.toLanguageButton.tag:
					vc.buttonIndex = tag
					vc.selectedlanguageRow = self.toLanguage.index
					self.navigationController?.present(vc, animated: true, completion: nil)
				default:
					break
			}
		}

		textViewsStackView.inputTextViewStack.onClearTapped = { [weak self] in
			guard let self = self else { return }
			
			let translation = TranslationModel()
			translation.configure(inputText: self.textViewsStackView.inputTextViewStack.inputTextView.text,
														outputText: self.textViewsStackView.outputTextViewStack.outputTextView.text,
														fromLanguage: self.fromLanguage.rawValue,
														toLanguage: self.toLanguage.rawValue)
			
			let existingTranslation = self.realmService.realm.object(ofType: TranslationModel.self, forPrimaryKey: translation.compoundKey)
			if existingTranslation == nil {
				self.realmService.save(translation)
				self.populate(with: self.translations)
			}
			
			self.synthesizer.stopSpeaking(at: .immediate)
			
			if !self.textViewsStackView.inputTextViewStack.inputTextView.isFirstResponder {
				self.textViewsStackView.inputTextViewStack.inputTextView.text = nil
				self.textViewsStackView.inputTextViewStack.inputTextView.becomeFirstResponder()
			}
			
			UIView.animate(withDuration: 0.15) {
				self.textViewsStackView.outputTextViewStack.isHidden = true
				self.textViewsStackView.outputTextViewStack.outputTextView.text = nil
				self.textViewsStackView.inputTextViewStack.clearButton.isHidden = true
			} completion: { (_) in
				self.textViewsStackView.inputTextViewStack.removeArrangedSubview(self.textViewsStackView.inputTextViewStack.clearButton)
			}
			
			self.textViewsStackView.inputTextViewStack.clearButton.isEnabled = false
		}
		
		
		textViewsStackView.outputTextViewStack.onPronouncePressed = { [weak self] in
			guard let self = self, let text = self.textViewsStackView.outputTextViewStack.outputTextView.text else { return }
			if !self.textViewsStackView.outputTextViewStack.isSpeakerPressed {
				self.textViewsStackView.outputTextViewStack.isSpeakerPressed = true
				let utterance = AVSpeechUtterance(string: text)
				utterance.voice = AVSpeechSynthesisVoice(language: self.toLanguage.rawValue)
				self.synthesizer.speak(utterance)
			} else {
				self.textViewsStackView.outputTextViewStack.isSpeakerPressed = false
				self.synthesizer.stopSpeaking(at: .immediate)
			}
		}
		
		textViewsStackView.outputTextViewStack.onSharePressed = { [weak self] in
			guard let self = self, let text = self.textViewsStackView.outputTextViewStack.outputTextView.text  else { return }
			let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
			self.present(activityController, animated: true)
		}
		
		translations = realmService.realm.objects(TranslationModel.self).sorted(byKeyPath: "timestamp", ascending: false)
		
		// MARK: - Всякая херота
		let titleImage = UIImage(named: "hyyandex")
		let titleImageView = UIImageView(image: titleImage)
		titleImageView.contentMode = .scaleAspectFill
		navigationItem.titleView = titleImageView
		
//		navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "#FFCC00")
		navigationController?.navigationBar.barTintColor = .white
		
		
//		hideKeyboardWhenTappedAround()
		
		view.backgroundColor = .systemGray5
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		populate(with: translations)
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
//			textViewsStackView.inputTextViewStack.clearButton.isHidden = textView.text.isEmpty
			if textView.text.count >= 1 {
				UIView.animate(withDuration: 0.2) {
					self.textViewsStackView.inputTextViewStack.addArrangedSubview(self.textViewsStackView.inputTextViewStack.clearButton)
					self.textViewsStackView.outputTextViewStack.isHidden = false
					self.textViewsStackView.inputTextViewStack.clearButton.isHidden = false
				}
			} else if textView.text.count == 0 {
				UIView.animate(withDuration: 0.15) {
					self.textViewsStackView.outputTextViewStack.isHidden = true
					self.textViewsStackView.outputTextViewStack.outputTextView.text = nil
					self.textViewsStackView.inputTextViewStack.clearButton.isHidden = true
					self.textViewsStackView.inputTextViewStack.clearButton.isEnabled = false
				} completion: { (_) in
					self.textViewsStackView.inputTextViewStack.removeArrangedSubview(self.textViewsStackView.inputTextViewStack.clearButton)
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
		if (range.location == 0 && text == " ") {
			return false
		}
		
		if let character = text.first, character.isNewline {
			textView.resignFirstResponder()
			return false
		}
		
		if textViewsStackView.outputTextViewStack.outputTextView.isHidden == true {
			self.textViewsStackView.outputTextViewStack.outputTextView.text = nil
		}
		return true
	}
}

extension MainViewController: LanguagesViewControllerDelegate {
	func swapLanguagesIfMirrored() {
		(fromLanguage, toLanguage) = (toLanguage, fromLanguage)
		if !self.textViewsStackView.outputTextViewStack.outputTextView.isHidden {
			(self.textViewsStackView.inputTextViewStack.inputTextView.text, self.textViewsStackView.outputTextViewStack.outputTextView.text) = (self.textViewsStackView.outputTextViewStack.outputTextView.text, self.textViewsStackView.inputTextViewStack.inputTextView.text)
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
		textViewsStackView.outputTextViewStack.isSpeakerPressed  = true
	}
	
	func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
		textViewsStackView.outputTextViewStack.isSpeakerPressed  = false
	}
}

extension MainViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let item = dataSource.itemIdentifier(for: indexPath) else {
			collectionView.deselectItem(at: indexPath, animated: true)
			return
		}
		
		textViewsStackView.inputTextViewStack.inputTextView.textColor = UIColor.black
		textViewsStackView.inputTextViewStack.inputTextView.text = item.inputText
		textViewsStackView.outputTextViewStack.outputTextView.text = item.outputText
		fromLanguage = Languages(rawValue: item.fromLanguage)
		toLanguage = Languages(rawValue: item.toLanguage)
		
		UIView.animate(withDuration: 0.2) {
			self.textViewsStackView.outputTextViewStack.isHidden = false
		}

		self.textViewsStackView.inputTextViewStack.addArrangedSubview(self.textViewsStackView.inputTextViewStack.clearButton)
		self.textViewsStackView.inputTextViewStack.clearButton.isHidden = false
		collectionView.deselectItem(at: indexPath, animated: true)
	}
}


