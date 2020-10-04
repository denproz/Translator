import UIKit
import SnapKit

protocol LanguagesViewControllerDelegate: class {
	func onLanguageChosen(language: Languages, buttonIndex: Int)
}

class LanguagesViewController: UIViewController {
	var buttonIndex: Int!
	var selectedlanguageRow: Int!
	var languages = Languages.allCases
	weak var delegate: LanguagesViewControllerDelegate?
	
	let collectionView: UICollectionView = {
		var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		configuration.backgroundColor = .systemGray5
		
		let layout = UICollectionViewCompositionalLayout.list(using: configuration)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .systemGray5
		return collectionView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(collectionView)
		collectionView.snp.makeConstraints { (make) in
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		collectionView.layoutIfNeeded()
		
		collectionView.delegate = self
		collectionView.dataSource = self
	}
	
}

extension LanguagesViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return Languages.allCases.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let language = Languages.allCases[indexPath.row]
		let registration = UICollectionView.CellRegistration<UICollectionViewListCell, Languages> { (cell, indexPath, language) in
			var configuration = cell.defaultContentConfiguration()
			configuration.text = language.languageName
			configuration.secondaryText = language.nativeLanguageName
			configuration.image = language.image
			cell.contentConfiguration = configuration
		}
		
		let cell = collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: language)
		
		if indexPath.row == selectedlanguageRow {
			cell.accessories = [.checkmark()]
		} else {
			cell.accessories = []
		}
		return cell
	}
}


extension LanguagesViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let language = Languages.allCases[indexPath.item]
		delegate?.onLanguageChosen(language: language, buttonIndex: buttonIndex)
		//		navigationController?.popViewController(animated: true)
		dismiss(animated: true, completion: nil)
	}
}
