import UIKit
import SnapKit

protocol LanguagesViewControllerDelegate: class {
	func onLanguageChosen(language: Languages, buttonIndex: Int)
}

class LanguageCell: UITableViewCell {
	
}

class LanguagesViewController: UIViewController {
	var buttonIndex: Int!
	weak var delegate: LanguagesViewControllerDelegate?
	
	let tableView: UITableView = {
		let tableView = UITableView()
		return tableView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) in
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.separatorStyle = .none
		tableView.register(LanguageCell.self, forCellReuseIdentifier: "LanguageCell")
	}
}

extension LanguagesViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Languages.allCases.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath)
		cell.textLabel?.text = Languages.allCases[indexPath.row].languageName
		return cell
	}
}

extension LanguagesViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let language = Languages.allCases[indexPath.row]
		delegate?.onLanguageChosen(language: language, buttonIndex: buttonIndex)
		//		navigationController?.popViewController(animated: true)
		dismiss(animated: true, completion: nil)
	}
}
