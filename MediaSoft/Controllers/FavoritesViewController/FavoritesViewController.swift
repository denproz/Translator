import UIKit
import RealmSwift

class FavoritesViewController: UIViewController {
	
	let realmService = RealmService.shared
	var translations: Results<TranslationModel>!
	var notificationToken: NotificationToken?
	
	lazy var noFavoritesLabel: UILabel = {
		let label = UILabel()
		label.text = "У Вас нет избранных переводов"
		label.font = UIFont.systemFont(ofSize: 20)
		label.textColor = .placeholderText
		label.isHidden = true
		label.sizeToFit()
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	var dataSource: UICollectionViewDiffableDataSource<Int, TranslationModel>!
	
	lazy var collectionView: UICollectionView = {
		var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		configuration.backgroundColor = .systemGray5
		
		configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
			guard let self = self else { return nil }
			
			let delete = UIContextualAction(style: .destructive, title: nil, handler: { _, _, completion in
				guard let itemToUnfavorite = self.dataSource?.itemIdentifier(for: indexPath) else {
					completion(false)
					return
				}
				self.remove(itemToUnfavorite)
				try! self.realmService.realm.write {
					itemToUnfavorite.isFavorite = false
					self.realmService.realm.add(itemToUnfavorite, update: .modified)
				}
				
				completion(true)
			})
			
			delete.image = UIImage(systemName: "star.slash.fill")
			
			let deleteAction = UISwipeActionsConfiguration(actions: [delete])
			return deleteAction
		}
		
		
		let layout = UICollectionViewCompositionalLayout.list(using: configuration)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.delegate = self
		return collectionView
	}()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemGray5
		navigationItem.title = "Избранное"
		navigationController?.navigationBar.prefersLargeTitles = true
		
		translations = realmService.realm.objects(TranslationModel.self)
			.filter("isFavorite = true")
			.sorted(byKeyPath: "isFavoriteTimestamp", ascending: false)
		
		view.addSubview(collectionView)
		collectionView.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		setupCollectionView()
		collectionView.layoutIfNeeded()
		self.populate(with: translations)
		
		view.addSubview(noFavoritesLabel)
		noFavoritesLabel.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
		}
		
		self.noFavoritesLabel.isHidden = !self.translations.isEmpty
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		RealmService.shared.observeRealmErrors(in: self) { error in
			print(error ?? "")
		}
		
		notificationToken = translations.observe { [weak self] changes in
			guard let self = self else { return }
			self.noFavoritesLabel.isHidden = !self.translations.isEmpty
		}
		
		self.populate(with: translations)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		RealmService.shared.stopObservingRealmErrors(in: self)
		
		notificationToken?.invalidate()
		
	}
	
	func setupCollectionView() {
		let registration = UICollectionView.CellRegistration<UICollectionViewListCell, TranslationModel> { (cell, indexPath, translation) in
			var configuration = cell.defaultContentConfiguration()
			configuration.text = translation.inputText
			configuration.secondaryText = translation.outputText
			
			let topImage = Languages(rawValue: translation.fromLanguage)!.image
			let bottomImage = Languages(rawValue: translation.toLanguage)!.image
			let languagesImage = topImage.mergeWith(image: bottomImage)
			
			configuration.image = languagesImage
			cell.contentConfiguration = configuration
		}
		
		dataSource = UICollectionViewDiffableDataSource<Int, TranslationModel>(collectionView: collectionView) { (collectionView, indexPath, translation) in
			let cell = collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: translation)
			return cell
		}
	}
	
	func populate(with translation: Results<TranslationModel>, animated: Bool = false) {
		var snapshot = NSDiffableDataSourceSnapshot<Int, TranslationModel>()
		snapshot.appendSections([0])
		translations.forEach { (translation) in
			snapshot.appendItems([translation])
		}
		dataSource?.apply(snapshot, animatingDifferences: animated)
	}
	
	func remove(_ translation: TranslationModel) {
		var snapshot = dataSource?.snapshot()
		snapshot?.deleteItems([translation])
		dataSource?.apply(snapshot!, animatingDifferences: true)
	}
	
}

extension FavoritesViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
	}
}

