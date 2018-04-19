//
//  NeighborhoodCollectionViewCell.swift
//  Aptfit-iOS
//
//  Created by Zain N. on 4/17/18.
//  Copyright © 2018 Mapfit. All rights reserved.
//

import UIKit

class NeighborhoodCollectionViewCell: UICollectionViewCell {
    

    lazy var neighborhood: UILabel = UILabel()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpCell(){
        self.contentView.addSubview(neighborhood)
        self.neighborhood.translatesAutoresizingMaskIntoConstraints = false
        self.neighborhood.widthAnchor.constraint(equalTo: self.contentView.widthAnchor).isActive = true
        self.neighborhood.heightAnchor.constraint(equalTo: self.contentView.heightAnchor).isActive = true
        self.neighborhood.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.neighborhood.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.neighborhood.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        self.neighborhood.textColor = UIColor.darkGray
        self.neighborhood.font = UIFont.systemFont(ofSize: 14)
        self.neighborhood.textAlignment = .center
        self.neighborhood.adjustsFontSizeToFitWidth = true
        
        
        self.neighborhood.text = neighborhood.text

    }
    
}
