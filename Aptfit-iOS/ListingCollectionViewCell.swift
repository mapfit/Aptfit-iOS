//
//  ListingCollectionViewCell.swift
//  Aptfit-iOS
//
//  Created by Zain N. on 4/17/18.
//  Copyright © 2018 Mapfit. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ListingCollectionViewCell: UICollectionViewCell {
    
    lazy var shadowCard: UIView = UIView()
    lazy var card: UIView = UIView()
    
    lazy var topBorder: UIImageView = UIImageView()
    lazy var mainImage: UIImageView = UIImageView()
    lazy var priceButton: UIButton = UIButton()
    
    lazy var bottomLabelStackView: UIStackView = UIStackView()
    lazy var addressLabel: UILabel = UILabel()
    lazy var neighborhoodLabel: UILabel = UILabel()
    lazy var detailLabel: UILabel = UILabel()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpCellVericalScrollingCell(listing: Listing){
        
        self.card.layer.cornerRadius = 9
       
        self.card.layer.masksToBounds = false
        
        self.card.backgroundColor = .white
        self.card.layer.shadowRadius = 1
        self.card.layer.shadowColor = UIColor(red: 19/255, green: 40/255, blue: 54/255, alpha: 0.2).cgColor
        self.card.layer.zPosition = 1
        self.card.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.card.layer.shadowOpacity = 1
        
        self.shadowCard.layer.cornerRadius = 9
        self.shadowCard.backgroundColor = .white
        self.shadowCard.layer.shadowRadius = 1
        self.shadowCard.layer.shadowColor = UIColor(red: 19/255, green: 40/255, blue: 54/255, alpha: 0.2).cgColor
        self.shadowCard.layer.zPosition = 1
        self.shadowCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.shadowCard.layer.shadowOpacity = 1
        
        self.contentView.addSubview(shadowCard)
        self.contentView.addSubview(card)
        
        self.card.addSubview(mainImage)
        self.card.addSubview(priceButton)
        self.card.addSubview(bottomLabelStackView)
        self.card.addSubview(topBorder)
        
        self.shadowCard.translatesAutoresizingMaskIntoConstraints = false
        self.card.translatesAutoresizingMaskIntoConstraints = false
        self.mainImage.translatesAutoresizingMaskIntoConstraints = false
        self.priceButton.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLabelStackView.translatesAutoresizingMaskIntoConstraints = false

        self.shadowCard.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.97).isActive = true
        self.shadowCard.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.97).isActive = true
        self.shadowCard.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.shadowCard.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        
        self.card.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.97).isActive = true
        self.card.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.97).isActive = true
        self.card.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.card.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
         self.card.clipsToBounds = true

        
        
        self.mainImage.widthAnchor.constraint(equalTo: self.card.widthAnchor).isActive = true
        self.mainImage.heightAnchor.constraint(equalToConstant: 180).isActive = true
        self.mainImage.topAnchor.constraint(equalTo: self.card.topAnchor).isActive = true
        self.mainImage.centerXAnchor.constraint(equalTo: self.card.centerXAnchor).isActive = true
        self.mainImage.contentMode = .scaleAspectFill
        
   

        self.priceButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
        self.priceButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        self.priceButton.topAnchor.constraint(equalTo: self.card.topAnchor, constant: 5).isActive = true
        self.priceButton.leadingAnchor.constraint(equalTo: self.card.leadingAnchor, constant: 5).isActive = true
        self.priceButton.imageView?.contentMode = .scaleAspectFit
        self.priceButton.setBackgroundImage(#imageLiteral(resourceName: "priceButton"), for: .normal)

        
        let attString = NSMutableAttributedString(string: "\(listing.price)")
        attString.addAttributes([NSAttributedStringKey.font : UIFont.init(name: aptfitFont, size: 14),NSAttributedStringKey.foregroundColor : UIColor.white ] , range: NSMakeRange(0, attString.length))
        
        self.priceButton.setAttributedTitle(attString, for: .normal)
        
        
        self.bottomLabelStackView.widthAnchor.constraint(equalTo: self.card.widthAnchor, multiplier: 0.95).isActive = true
        //self.bottomLabelStackView.bottomAnchor.constraint(equalTo: self.card.bottomAnchor, constant: -10).isActive = true
        self.bottomLabelStackView.topAnchor.constraint(equalTo: self.mainImage.bottomAnchor, constant: 15).isActive = true
        self.bottomLabelStackView.heightAnchor.constraint(equalToConstant: 69).isActive = true
        self.bottomLabelStackView.centerXAnchor.constraint(equalTo: self.card.centerXAnchor).isActive = true
        
        self.bottomLabelStackView.axis = .vertical
        self.bottomLabelStackView.addArrangedSubview(addressLabel)
        self.bottomLabelStackView.addArrangedSubview(neighborhoodLabel)
        self.bottomLabelStackView.addArrangedSubview(detailLabel)
 
        
        bottomLabelStackView.distribution = .fillEqually
        
        self.addressLabel.textColor = UIColor.black
        self.neighborhoodLabel.textColor = UIColor(red: 154/255, green: 155/255, blue: 163/255, alpha: 1)
        self.detailLabel.textColor = UIColor.black
        
        self.addressLabel.font = UIFont.init(name: aptfitFont, size: 15)
        self.neighborhoodLabel.font = UIFont.init(name: aptfitFont, size: 14)
        self.detailLabel.font = UIFont.init(name: aptfitFont, size: 14)
        
        if let downloadURL = URL(string: listing.imageUrl) {
            
            mainImage.af_setImage(withURL: downloadURL)
            
        }
        
        self.mainImage.clipsToBounds = true
        
        self.addressLabel.text = listing.address
        self.neighborhoodLabel.text = listing.neighborhood
        self.detailLabel.text = "\(listing.bedroomCount) BD  |  \(listing.bathroomCount) BA  |  \(listing.area) SF"

    }
    
    func setUpCellHorizontalScrollingCell(listing: Listing){
        
        self.card.layer.cornerRadius = 9
        
        self.card.clipsToBounds = true
        self.card.layer.masksToBounds = true
        
        self.card.backgroundColor = .white
        self.card.layer.shadowRadius = 1
        self.card.layer.shadowColor = UIColor(red: 19/255, green: 40/255, blue: 54/255, alpha: 0.2).cgColor
        self.card.layer.zPosition = 1
        self.card.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.card.layer.shadowOpacity = 1
        
        
        self.contentView.addSubview(card)
        self.card.addSubview(mainImage)
        self.card.addSubview(priceButton)
        self.card.addSubview(bottomLabelStackView)
        
        
        
        self.card.translatesAutoresizingMaskIntoConstraints = false
        self.mainImage.translatesAutoresizingMaskIntoConstraints = false
        self.priceButton.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLabelStackView.translatesAutoresizingMaskIntoConstraints = false
       
        
        self.card.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.97).isActive = true
        self.card.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.97).isActive = true
        self.card.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.card.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        
        
        self.mainImage.widthAnchor.constraint(equalTo: self.card.widthAnchor).isActive = true
        self.mainImage.heightAnchor.constraint(equalToConstant: 107).isActive = true
        self.mainImage.topAnchor.constraint(equalTo: self.card.topAnchor).isActive = true
        self.mainImage.centerXAnchor.constraint(equalTo: self.card.centerXAnchor).isActive = true
        self.mainImage.contentMode = .scaleAspectFill
        self.mainImage.clipsToBounds = true
        
     
        
        self.bottomLabelStackView.widthAnchor.constraint(equalTo: self.card.widthAnchor, multiplier: 0.95).isActive = true
        self.bottomLabelStackView.topAnchor.constraint(equalTo: self.mainImage.bottomAnchor, constant: 15).isActive = true
        self.bottomLabelStackView.heightAnchor.constraint(equalToConstant: 59).isActive = true
        self.bottomLabelStackView.centerXAnchor.constraint(equalTo: self.card.centerXAnchor).isActive = true
        
        self.bottomLabelStackView.axis = .vertical
        self.bottomLabelStackView.addArrangedSubview(addressLabel)
        self.bottomLabelStackView.addArrangedSubview(neighborhoodLabel)
        self.bottomLabelStackView.addArrangedSubview(detailLabel)
        
        
        bottomLabelStackView.distribution = .fillEqually
        
        self.addressLabel.textColor = UIColor.black
        self.neighborhoodLabel.textColor = UIColor(red: 154/255, green: 155/255, blue: 163/255, alpha: 1)
        self.detailLabel.textColor = UIColor.black
        
        self.addressLabel.font = UIFont.init(name: aptfitFont, size: 13)
        self.neighborhoodLabel.font = UIFont.init(name: aptfitFont, size: 12)
        self.detailLabel.font = UIFont.init(name: aptfitFont, size: 12)
        
        if let downloadURL = URL(string: listing.imageUrl) {
            mainImage.af_setImage(withURL: downloadURL)
        }
        
        self.addressLabel.text = listing.address
        self.neighborhoodLabel.text = listing.neighborhood
        self.detailLabel.text = "\(listing.bedroomCount) BD  |  \(listing.bathroomCount) BA  |  \(listing.area) SF"
        
    }
    
    func removeHighlight(){
        self.topBorder.removeFromSuperview()
    }
    
    func hightlight() {
      
        self.card.addSubview(topBorder)
        self.topBorder.translatesAutoresizingMaskIntoConstraints = false
        self.topBorder.widthAnchor.constraint(equalTo: self.card.widthAnchor).isActive = true
        self.topBorder.heightAnchor.constraint(equalToConstant: 2).isActive = true
        self.topBorder.topAnchor.constraint(equalTo: self.card.topAnchor).isActive = true
        self.topBorder.centerXAnchor.constraint(equalTo: self.card.centerXAnchor).isActive = true
        self.topBorder.contentMode = .scaleAspectFill
        self.topBorder.image = #imageLiteral(resourceName: "cellBorder")
        
        
    }
    
}

extension UIView
{
    func roundCorners(corners:UIRectCorner, radius: CGFloat)
    {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
