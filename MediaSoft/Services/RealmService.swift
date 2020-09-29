import Foundation
import RealmSwift

class RealmService {
	private init() {}
	static let shared = RealmService()
	
	var realm = try! Realm()
	
	func save<T: Object>(_ object: T) {
		do {
			try realm.write {
				realm.add(object)
				print("SAVED TO REALM")
			}
		} catch {
			postRealmError(error)
		}
	}
	
//	func get<T: Object>(_ object: T) -> Results<T> {
//		return realm.objects(T.self)
//	}
	
	func delete<T: Object>(_ object: T) {
		do {
			try realm.write {
				realm.delete(object)
			}
		} catch {
			postRealmError(error)
		}
	}
}

extension RealmService {
	func postRealmError(_ error: Error) {
		NotificationCenter.default.post(name: NSNotification.Name("RealmError"), object: error)
	}
	
	func observeRealmErrors(in vc: UIViewController, completion: @escaping (Error?) -> Void) {
		NotificationCenter.default.addObserver(forName: NSNotification.Name("RealmError"),
																					 object: nil,
																					 queue: nil) { notification in
																				   completion(notification.object as? Error)
		}
	}
	
	func stopObservingRealmErrors(in vc: UIViewController) {
		NotificationCenter.default.removeObserver(vc, name: NSNotification.Name("RealmError"), object: nil)
	}
}
