import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		
		window = UIWindow(frame: windowScene.coordinateSpace.bounds)
		window?.windowScene = windowScene
		
		if #available(iOS 13.0, *) {
			window?.overrideUserInterfaceStyle = .light
		}
		
		let mainVC = MainViewController()
		let favoritesVC = FavoritesViewController()
		
		let tabBarVC = UITabBarController()
		tabBarVC.viewControllers = [mainVC, favoritesVC].map {
			UINavigationController(rootViewController: $0)
		}
		
		mainVC.configureTabBarItem(title: "Перевод", unselectedName: "house", selectedName: "house.fill")
		favoritesVC.configureTabBarItem(title: "Избранное", unselectedName: "star", selectedName: "star.fill")
		
		window?.rootViewController = tabBarVC
		window?.makeKeyAndVisible()
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		
	}
}

