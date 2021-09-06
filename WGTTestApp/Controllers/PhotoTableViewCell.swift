import UIKit

class PhotoTableViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func didMoveToSuperview() {
        super .didMoveToSuperview()
        
        imageView.layer.cornerRadius = 10
    }
    
}
