import UIKit

class TranslationContentView: UIView, UIContentView {
	let inputLabel = UILabel()
	let outputLabel = UILabel()
	
	private var currentConfiguration: TranslationContentConfiguration!
	var configuration: UIContentConfiguration {
		get {
			currentConfiguration
		}
		set {
			// Make sure the given configuration is of type SFSymbolContentConfiguration
			guard let newConfiguration = newValue as? TranslationContentConfiguration else {
				return
			}
			
			// Apply the new configuration to SFSymbolVerticalContentView
			// also update currentConfiguration to newConfiguration
			apply(configuration: newConfiguration)
		}
	}
	
	init(configuration: TranslationContentConfiguration) {
		super.init(frame: .zero)
		// Create the content view UI
		setupAllViews()
		
		// Apply the configuration (set data to UI elements / define custom content view appearance)
		apply(configuration: configuration)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

private extension TranslationContentView {
	private func setupAllViews() {
		inputLabel.textAlignment = .left
		outputLabel.textAlignment = .left

		let labelsStackView = UIStackView(arrangedSubviews: [inputLabel, outputLabel])
		labelsStackView.axis = .vertical
		labelsStackView.spacing = 4
		let cellStackView = UIStackView(arrangedSubviews: [labelsStackView])
		
		addSubview(cellStackView)
		
		cellStackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			cellStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			cellStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
			cellStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
			cellStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
		])
		
	}
	
	private func apply(configuration: TranslationContentConfiguration) {
		// Only apply configuration if new configuration and current configuration are not the same
		guard currentConfiguration != configuration else {
			return
		}
		
		// Replace current configuration with new configuration
		currentConfiguration = configuration
		
		// Set data to UI elements
		inputLabel.text = configuration.inputText
		outputLabel.text = configuration.outputText
	}
}
