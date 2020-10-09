import UIKit

extension UIImage {
	func mergeWith(image: UIImage) -> UIImage {
		let topImage = self
		
		let size = CGSize(width: (image.size.width), height: (image.size.height) + (image.size.height))
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		
		topImage.draw(in: CGRect(x:0, y:0, width:size.width, height: (topImage.size.height)))
		image.draw(in: CGRect(x:0, y:(topImage.size.height), width: size.width, height: (image.size.height)))
		
		let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		return newImage
	}
}
