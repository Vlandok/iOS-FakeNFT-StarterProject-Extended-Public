import UIKit
import SwiftUI

// MARK: - UIColor Legacy Aliases
// Цвета доступны напрямую через автогенерацию:
// - SwiftUI: Color(.ypBlack), Color(.ypWhite), Color(.ypBlue) и т.д.
// - UIKit: UIColor(resource: .ypBlack), UIColor(resource: .ypWhite) и т.д.

extension UIColor {
    
    // MARK: - Legacy Colors (для обратной совместимости со старым кодом)
    
    static let segmentActive = UIColor(resource: .ypBlack)
    static let segmentInactive = UIColor(resource: .ypLightGray)
    static let closeButton = UIColor(resource: .ypBlack)
}
