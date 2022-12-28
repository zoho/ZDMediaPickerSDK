//
//  ZDAlbumListCell.swift
//  LImitedPhotosGallery
//
//  Created by lakshmi-12493 on 06/04/22.
//

import UIKit
import Photos

class ZDAlbumListCell: UITableViewCell {

    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var count: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with collection : PHAssetCollection, isScanner : Bool){
        self.title.text = collection.localizedTitle
        self.selectionStyle = .none
        let assets = isScanner ? ZDAssets.getAsset(from: collection, with: .image) : ZDAssets.getAsset(from: collection)
        guard let asset = assets.firstObject else {return}
        self.thumbnailImage.getImageFromAsset(asset: asset)
        self.count.text = String(assets.count)
    }
}
