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
    
    func configure(with collection : PHAssetCollection){
        self.title.text = collection.localizedTitle
        self.selectionStyle = .none
        let assets = ZDAssets.getAsset(from: collection)
        if let asset = assets.firstObject{
            self.thumbnailImage.getImageFromAsset(asset: asset)
        }
        self.count.text = String(assets.count)
    }
}
