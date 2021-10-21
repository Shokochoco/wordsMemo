import Foundation
import UIKit

extension UINavigationController {

    open override var shouldAutorotate: Bool {

        if let vc = viewControllers.last {
            return vc.shouldAutorotate
        } else {
            return true
        }
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        if let vc = viewControllers.last {
            return vc.supportedInterfaceOrientations
        } else {
            return .portrait
        }
    }

}
