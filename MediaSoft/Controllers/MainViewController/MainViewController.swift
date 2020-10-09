import UIKit
import RxSwift
import RxCocoa
import Moya
import SnapKit
import NaturalLanguage
import AVFoundation
import RealmSwift
import Network

class MainViewController: UIViewController {
	lazy var languagesStackView: LanguagesStackView = {
		let stack = LanguagesStackView(fromLanguage: fromLanguage, toLanguage: toLanguage)
		return stack
	}()
	
	lazy var textviewsStack: TextViewsStackView = {
		let stack = TextViewsStackView()
		stack.inputStack.inputTextView.delegate = self
		stack.outputStack.outputTextView.delegate = self
		return stack
	}()
	/// Language to translate from
	var fromLanguage: Languages! = .ru {
		didSet {
			languagesStackView.fromLanguageButton.setTitle(fromLanguage.languageName, for: .normal)
		}
	}
	/// Language to translate into
	var toLanguage: Languages! = .en {
		didSet {
			languagesStackView.toLanguageButton.setTitle(toLanguage.languageName, for: .normal)
		}
	}
	
	let monitor = NWPathMonitor()
	/// Internet connectivity flag
	var isConnectionEstablished = false

	let realmService = RealmService.shared
	var translations: Results<RealmTranslation>!
	var notificationToken: NotificationToken?
	
	let disposeBag = DisposeBag()
	let translationProvider = MoyaProvider<YandexService>()
	
	// Speech generator
	lazy var synthesizer: AVSpeechSynthesizer = {
		let synthesizer = AVSpeechSynthesizer()
		synthesizer.delegate = self
		return synthesizer
	}()
	
	private lazy var dataSource = makeDataSource()
	private lazy var collectionView = makeCollectionView()
	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		checkForConnectivity()
		executeTranslation()
		handleActions()
		configureLanguages()
		configureViewsConstraints()
		
		collectionView.dataSource = dataSource
		translations = realmService.realm.objects(RealmTranslation.self).sorted(byKeyPath: "timestamp", ascending: false)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		RealmService.shared.observeRealmErrors(in: self) { error in
			print(error ?? "")
		}
		
		notificationToken = translations.observe { [weak self] changes in
			guard let self = self else { return }
			switch changes {
				case .initial(_):
					self.populate(with: self.translations)
				case .update(_, _, _, _):
					break
				case .error(_):
					break
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		RealmService.shared.stopObservingRealmErrors(in: self)
		notificationToken?.invalidate()
		// Save language changes
		UserDefaults.standard.set(fromLanguage.rawValue, forKey: "fromLanguage")
		UserDefaults.standard.set(toLanguage.rawValue, forKey: "toLanguage")
	}
}
// MARK: - Translation cell delegate
extension MainViewController: TappableStar {
	/// Configures the cell after it's been tapped
	/// - Parameter cell: Cell that has been tapped
	func onStarTapped(_ cell: TranslationListCell) {
		guard let indexPathTapped = collectionView.indexPath(for: cell),
					let translation = dataSource.itemIdentifier(for: indexPathTapped) else { return }
		translation.toggleFavorite()
		cell.toggleFavorite()
		_ = translation.isFavorite ? Vibration.medium.vibrate() : Vibration.warning.vibrate()
		
	}
}
// MARK: - Various
extension MainViewController {
	/// Uses Network framework to check if there's internet connection established
	private func checkForConnectivity() {
		self.monitor.pathUpdateHandler = { path in
			if path.status == .satisfied {
				self.isConnectionEstablished = true
			} else {
				self.isConnectionEstablished = false
			}
		}
		// Dispatch network availability checking onto a background thread
		let queue = DispatchQueue.global(qos: .background)
		monitor.start(queue: queue)
	}
	/// Restores the state of languages,
	/// otherwise sets them to default values
	private func configureLanguages() {
		fromLanguage = Languages(rawValue: UserDefaults.standard.string(forKey: "fromLanguage") ?? "ru")
		toLanguage = Languages(rawValue: UserDefaults.standard.string(forKey: "toLanguage") ?? "en")
	}
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		// Hide keyboard when the user drags the collection view
		textviewsStack.inputStack.inputTextView.resignFirstResponder()
	}
}

// MARK: - Views Configuration
extension MainViewController {
	private func configureViewsConstraints() {
		view.addSubview(languagesStackView)
		languagesStackView.snp.makeConstraints { (make) in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
			make.leading.equalToSuperview().offset(8)
			make.trailing.equalToSuperview().offset(-8)
			make.height.equalTo(50)
		}
		
		view.addSubview(textviewsStack)
		textviewsStack.snp.makeConstraints { (make) in
			make.top.equalTo(languagesStackView.snp.bottom)
			make.leading.equalToSuperview().offset(8)
			make.trailing.equalToSuperview().offset(-8)
		}
		
		view.addSubview(collectionView)
		collectionView.snp.makeConstraints { (make) in
			make.top.equalTo(textviewsStack.snp.bottom)
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		collectionView.layoutIfNeeded()
	}
}
// MARK: - Collection View Configuration
extension MainViewController {
	private func makeCollectionView() -> UICollectionView {
		var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		configuration.backgroundColor = .systemGray5
		configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
			guard let self = self else { return nil }
			let delete = UIContextualAction(style: .destructive, title: nil, handler: { _, _, completion in
				guard let itemToDelete = self.dataSource.itemIdentifier(for: indexPath) else {
					completion(false)
					return
				}
				self.remove(itemToDelete)
				try! self.realmService.realm.write {
					self.realmService.realm.delete(itemToDelete)
				}
				completion(true)
			})
			
			delete.image = UIImage(systemName: "trash")
			let deleteAction = UISwipeActionsConfiguration(actions: [delete])
			return deleteAction
		}
		
		let layout = UICollectionViewCompositionalLayout.list(using: configuration)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .systemGray5
		collectionView.keyboardDismissMode = .onDrag
		collectionView.delegate = self
		return collectionView
	}
}
// MARK: - Cell Registration
extension MainViewController {
	private func makeCellRegistration() -> UICollectionView.CellRegistration<TranslationListCell, RealmTranslation> {
		UICollectionView.CellRegistration { cell, indexPath, translation in
			cell.tapper = self
			cell.translation = translation
		}
	}
}
// MARK: - Collection View Diffable Data Source
extension MainViewController {
	private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, RealmTranslation> {
		let registration = makeCellRegistration()
		
		return UICollectionViewDiffableDataSource<Int, RealmTranslation>(collectionView: collectionView) { collectionView, indexPath, translation in
			let cell = collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: translation)
			cell.toggleFavorite()
			return cell
		}
	}
	
	func populate(with translation: Results<RealmTranslation>) {
		var snapshot = NSDiffableDataSourceSnapshot<Int, RealmTranslation>()
		snapshot.appendSections([0])
		translations.forEach { translation in
			snapshot.appendItems([translation])
		}
		dataSource.apply(snapshot, animatingDifferences: false)
	}
	
	func remove(_ translation: RealmTranslation) {
		var snapshot = dataSource.snapshot()
		snapshot.deleteItems([translation])
		dataSource.apply(snapshot)
	}
}
// MARK: - Collection View Delegate
extension MainViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let item = dataSource.itemIdentifier(for: indexPath) else {
			collectionView.deselectItem(at: indexPath, animated: true)
			return
		}
		
		textviewsStack.inputStack.inputTextView.textColor = UIColor.black
		textviewsStack.inputStack.inputTextView.text = item.inputText
		textviewsStack.outputStack.outputTextView.text = item.outputText
		fromLanguage = Languages(rawValue: item.fromLanguage)
		toLanguage = Languages(rawValue: item.toLanguage)
		
		UIView.animate(withDuration: 0.2) {
			self.textviewsStack.outputStack.isHidden = false
		}
		self.textviewsStack.inputStack.addArrangedSubview(self.textviewsStack.inputStack.clearButton)
		self.textviewsStack.outputStack.pronounceButton.isEnabled = true
		self.textviewsStack.outputStack.shareButton.isEnabled = true
		self.textviewsStack.inputStack.clearButton.isHidden = false
		self.textviewsStack.inputStack.clearButton.isEnabled = true
		
		collectionView.deselectItem(at: indexPath, animated: true)
	}
}


