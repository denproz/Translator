import UIKit
import RealmSwift
import SnapKit

protocol TappableStar: class {
	func onStarTapped(_ cell: TranslationListCell)
}

class TranslationListCell: UICollectionViewListCell {
	let starButton: UIButton = {
		let starButton = UIButton()
		let starImage = UIImage(systemName: "star")!
		starButton.setImage(starImage, for: .normal)
		starButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		starButton.tintColor = .systemRed
		return starButton
	}()
	
	var translation: TranslationModel!
	weak var tapper: TappableStar?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		let customAccessory = UICellAccessory.CustomViewConfiguration(
			customView: starButton,
			placement: .trailing(displayed: .always))
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(starButtonPressed(_:)))
		customAccessory.customView.addGestureRecognizer(tapGesture)
		
		accessories = [.customView(configuration: customAccessory)]
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc private func starButtonPressed(_ sender: UIButton) {
		tapper?.onStarTapped(self)
	}
	
	override func updateConfiguration(using state: UICellConfigurationState) {
		if translation.isInvalidated {
			return
		}
		// Create new configuration object and update it base on state
		var newConfiguration = TranslationContentConfiguration().updated(for: state)
		// Update any configuration parameters related to data item
		
		newConfiguration.inputText = translation?.inputText
		newConfiguration.outputText = translation?.outputText

		contentConfiguration = newConfiguration
	}
	
	func toggleFavorite() {
		let image = translation.isFavorite ? UIImage(systemName: "star.fill")!
																		   : UIImage(systemName: "star")!
		
		starButton.setImage(image, for: .normal)
	}
}
