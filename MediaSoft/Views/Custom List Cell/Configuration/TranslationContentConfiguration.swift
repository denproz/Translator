import UIKit

struct TranslationContentConfiguration: UIContentConfiguration, Hashable {
	var inputText: String?
	var outputText: String?
	
	func makeContentView() -> UIView & UIContentView {
		return TranslationContentView(configuration: self)
	}
	
	func updated(for state: UIConfigurationState) -> TranslationContentConfiguration {
		guard state is UICellConfigurationState else {
			return self
		}
		
		let updatedConfiguration = self
		return updatedConfiguration
	}
}
