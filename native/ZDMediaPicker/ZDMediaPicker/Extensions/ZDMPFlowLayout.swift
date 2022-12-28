//
//  TagCustomFlowLayout.swift
//  TagsInRadar
//
//  Created by Rathish Marthandan T on 21/10/21.
//

import UIKit

class ZDMPFlowLayout: UICollectionViewFlowLayout {

    override var flipsHorizontallyInOppositeLayoutDirection: Bool{
        true
    }
    
    override var developmentLayoutDirection: UIUserInterfaceLayoutDirection{
        UIView.shouldForceRTL ? .rightToLeft : .leftToRight
    }
    
    override init() {
        super.init()
        self.itemSize = UICollectionViewFlowLayout.automaticSize
        self.estimatedItemSize = CGSize.init(width: 1, height: 1)
        self.minimumInteritemSpacing = 1.0
        self.minimumLineSpacing = 1.0
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil}
        makeLeftAlignment(on: attributes)
        return attributes
    }
    
    func makeLeftAlignment(on att : [UICollectionViewLayoutAttributes]){
        var x: CGFloat = sectionInset.left
        var y: CGFloat = sectionInset.top
        att.forEach { [weak self] a in
            guard let self = self else {return}
            switch self.scrollDirection {
            case .horizontal:
                break
            case .vertical:
                if a.frame.origin.y >= y {
                    x = sectionInset.left
                }
                
                a.frame.origin.x = x
                
                x += a.frame.width + minimumInteritemSpacing
                y = max(a.frame.maxY , y)
            @unknown default:
                break
            }
        }
    }
    

}
