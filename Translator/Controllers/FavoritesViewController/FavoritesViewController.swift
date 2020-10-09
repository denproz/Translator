import UIKit
import RealmSwift
import SnapKit

final class FavoritesViewController: UIViewController {
	private lazy var noFavoritesLabel: UILabel = {
		let label = UILabel()
		label.text = "У Вас нет избранных переводов"
		label.font = UIFont.systemFont(ofSize: 20)
		label.textColor = .placeholderText
		label.isHidden = true
		label.sizeToFit()
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	private let realmService = RealmService.shared
	private var translations: Results<RealmTranslation>!
	private var notificationToken: NotificationToken?
	private lazy var collectionView = makeCollectionView()
	private lazy var dataSource = makeDataSource()
	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		translations = realmService.realm.objects(RealmTranslation.self)
			.filter("isFavorite = true")
			.sorted(byKeyPath: "isFavoriteTimestamp", ascending: false)
		
		view.addSubview(collectionView)
		collectionView.dataSource = dataSource
		collectionView.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		collectionView.layoutIfNeeded()
		
		view.addSubview(noFavoritesLabel)
		noFavoritesLabel.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
		}
		
		populate(with: translations)
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
		
		populate(with: translations)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		RealmService.shared.stopObservingRealmErrors(in: self)
		notificationToken?.invalidate()
	}
}
// MARK: - Collection View Configuration
extension FavoritesViewController {
	private func makeCollectionView() -> UICollectionView {
		var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		configuration.backgroundColor = .systemGray5
		configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
			guard let self = self else { return nil }
			
			let delete = UIContextualAction(style: .destructive, title: nil, handler: { _, _, completion in
				guard let itemToUnfavorite = self.dataSource.itemIdentifier(for: indexPath) else {
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
	}
}
// MARK: - Cell Registration
extension FavoritesViewController {
	private func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, RealmTranslation> {
		UICollectionView.CellRegistration { cell, indexPath, translation in
			var configuration = cell.defaultContentConfiguration()
			configuration.text = translation.inputText
			configuration.secondaryText = translation.outputText
			
			let topImage = Languages(rawValue: translation.fromLanguage)!.image
			let bottomImage = Languages(rawValue: translation.toLanguage)!.image
			let languagesImage = topImage.mergeWith(image: bottomImage)
			
			configuration.image = languagesImage
			cell.contentConfiguration = configuration
		}
	}
}
// MARK: - Collection View Diffable Data Source
extension FavoritesViewController {
	private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, RealmTranslation> {
		let registration = makeCellRegistration()
		
		return UICollectionViewDiffableDataSource<Int, RealmTranslation>(collectionView: collectionView) { collectionView, indexPath, translation in
			collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: translation)
		}
	}
	
	private func populate(with translation: Results<RealmTranslation>, animated: Bool = false) {
		var snapshot = NSDiffableDataSourceSnapshot<Int, RealmTranslation>()
		snapshot.appendSections([0])
		translations.forEach { (translation) in
			snapshot.appendItems([translation])
		}
		dataSource.apply(snapshot, animatingDifferences: animated)
	}
	
	func remove(_ translation: RealmTranslation) {
		var snapshot = dataSource.snapshot()
		snapshot.deleteItems([translation])
		dataSource.apply(snapshot, animatingDifferences: true)
	}
}
// MARK: - Colleciton View Delegates
extension FavoritesViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
	}
}

