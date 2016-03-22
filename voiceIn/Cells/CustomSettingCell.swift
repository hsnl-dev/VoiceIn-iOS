import UIKit
import Foundation
import Eureka

public final class SelectImageRow : _SelectImageRow<PushSelectorCell<UIImage>>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _SelectImageRow<Cell: CellType where Cell: BaseCell, Cell: TypedCellType, Cell.Value == UIImage>: SelectorRow<UIImage, Cell, ImagePickerController> {
    public required init(tag: String?) {
        super.init(tag: tag)
        self.displayValueFor = nil
    }
    
    public override func customDidSelect() {
        deselect()
    }
    
    public override func customUpdateCell() {
        super.customUpdateCell()
        cell.accessoryType = .None
        if let image = self.value {
            let imageView = UIImageView(frame: CGRectMake(0, 0, 44, 44))
            imageView.contentMode = .ScaleAspectFill
            imageView.image = image
            imageView.clipsToBounds = true
            cell.accessoryView = imageView
        }
        else{
            cell.accessoryView = nil
        }
    }
}