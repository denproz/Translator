import UIKit

struct TranslationContentConfiguration: UIContentConfiguration, Hashable {
	var inputText: String?
	var outputText: String?
	
	func makeContentView() -> UIView & UIContentView {
		return TranslationContentView(configuration: self)
	}
	
	func updated(for state: UIConfigurationState) -> TranslationContentConfiguration {
		// Make sure we are dealing with instance of UICellConfigurationState
		guard let state = state as? UICellConfigurationState else {
			return self
		}
		
		// Update self based on the current state
		var updatedConfiguration = self
//		if state.isHighlighted {
//			// Selected state
//			updatedConfiguration.starColor = .orange
//		} else {
//			// Other states
//			updatedConfiguration.starColor = .green
//		}
		return updatedConfiguration
	}
}
