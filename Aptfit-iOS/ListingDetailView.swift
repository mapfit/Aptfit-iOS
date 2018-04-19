//
//  ListingDetailView.swift
//  Aptfit-iOS
//
//  Created by Zain N. on 4/19/18.
//  Copyright © 2018 Mapfit. All rights reserved.
//

import UIKit
import Mapfit
import CoreLocation

class ListingDetailView: UIView {
    
    lazy var addressLabel: UILabel = UILabel()
    lazy var availbilityDateLabel: UILabel = UILabel()
    lazy var priceLabel: UILabel = UILabel()
    lazy var placeDetailLabel: UILabel = UILabel()
    lazy var mainImageView: UIImageView = UIImageView()
    lazy var neighborhoodTitleLabel: UILabel = UILabel()
    lazy var neighborhoodLabel: UILabel = UILabel()
    lazy var mapView: MFTMapView = MFTMapView()
    lazy var startBuildingButton: UIButton = UIButton()
    lazy var madeWithLoveLabel: UILabel = UILabel()
    var initialCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.73748242049333, longitude: -73.95733284034074)
    var textHeight: CGFloat = 17
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    func setUpView(listing: Listing){
        self.addSubview(addressLabel)
        self.addSubview(availbilityDateLabel)
        self.addSubview(priceLabel)
        self.addSubview(placeDetailLabel)
        self.addSubview(mainImageView)
        self.addSubview(neighborhoodTitleLabel)
        self.addSubview(neighborhoodLabel)
        self.addSubview(mapView)
        self.addSubview(startBuildingButton)
        self.addSubview(madeWithLoveLabel)
        
        self.addressLabel.translatesAutoresizingMaskIntoConstraints = false
        self.availbilityDateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.priceLabel.translatesAutoresizingMaskIntoConstraints = false
        self.placeDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        self.mainImageView.translatesAutoresizingMaskIntoConstraints = false
        self.neighborhoodTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.neighborhoodLabel.translatesAutoresizingMaskIntoConstraints = false
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.startBuildingButton.translatesAutoresizingMaskIntoConstraints = false
        self.madeWithLoveLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addressLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        self.addressLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
        self.addressLabel.heightAnchor.constraint(equalToConstant: textHeight).isActive = true
        self.addressLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 9).isActive = true
        
        self.addressLabel.textColor = .black
        self.addressLabel.font =  UIFont(name: "Helvetica", size: 17)

        self.availbilityDateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        self.availbilityDateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
        self.availbilityDateLabel.heightAnchor.constraint(equalToConstant: textHeight).isActive = true
        self.availbilityDateLabel.topAnchor.constraint(equalTo: self.addressLabel.bottomAnchor, constant: 11).isActive = true
        
        self.availbilityDateLabel.textColor = .gray
        self.availbilityDateLabel.font =  UIFont(name: "Helvetica", size: 14)
        
        self.priceLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        self.priceLabel.widthAnchor.constraint(equalToConstant: 130).isActive = true
        self.priceLabel.heightAnchor.constraint(equalToConstant: textHeight).isActive = true
        self.priceLabel.topAnchor.constraint(equalTo: self.availbilityDateLabel.bottomAnchor, constant: 13).isActive = true
        
        self.priceLabel.textColor = .black
        self.priceLabel.font =  UIFont(name: "Helvetica", size: 14)
        
        self.placeDetailLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        self.placeDetailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        self.placeDetailLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor).isActive = true
        self.placeDetailLabel.heightAnchor.constraint(equalToConstant: 19).isActive = true
        
        self.placeDetailLabel.textColor = .black
        self.placeDetailLabel.font =  UIFont(name: "Helvetica", size: 14)
        self.placeDetailLabel.textAlignment = .right

        self.mainImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.mainImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.mainImageView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        self.mainImageView.topAnchor.constraint(equalTo: self.priceLabel.bottomAnchor, constant: 14).isActive = true
        
        self.neighborhoodTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        self.neighborhoodTitleLabel.widthAnchor.constraint(equalToConstant: 130).isActive = true
        self.neighborhoodTitleLabel.heightAnchor.constraint(equalToConstant: textHeight + 2).isActive = true
        self.neighborhoodTitleLabel.topAnchor.constraint(equalTo: self.mainImageView.bottomAnchor, constant: 12).isActive = true
        
        self.neighborhoodTitleLabel.text = "Neighborhood"
        self.neighborhoodTitleLabel.font = UIFont.init(name: "Helvetica", size: 17)
        
        self.neighborhoodLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        self.neighborhoodLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        self.neighborhoodLabel.heightAnchor.constraint(equalToConstant: textHeight).isActive = true
        self.neighborhoodLabel.topAnchor.constraint(equalTo: self.neighborhoodTitleLabel.bottomAnchor, constant: 5).isActive = true
        
        self.neighborhoodLabel.font = UIFont.init(name: "Helvetica", size: 14)
        self.neighborhoodLabel.textColor = .gray
        
        
        
        self.mapView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.mapView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.mapView.heightAnchor.constraint(equalToConstant: 240).isActive = true
        self.mapView.topAnchor.constraint(equalTo: self.neighborhoodLabel.bottomAnchor, constant: 12).isActive = true
        self.mapView.mapOptions.setTheme(theme: .grayScale)
        self.mapView.setZoom(zoomLevel: 14)
        self.mapView.setCenter(position: initialCenter)
        
        self.startBuildingButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.startBuildingButton.topAnchor.constraint(equalTo: self.mapView.bottomAnchor, constant: 13).isActive = true
        self.startBuildingButton.heightAnchor.constraint(equalToConstant: textHeight).isActive = true
        self.startBuildingButton.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        self.madeWithLoveLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.madeWithLoveLabel.topAnchor.constraint(equalTo: self.startBuildingButton.bottomAnchor, constant: 14).isActive = true
        self.madeWithLoveLabel.heightAnchor.constraint(equalToConstant: textHeight).isActive = true
        self.madeWithLoveLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        self.startBuildingButton.setTitleColor(UIColor.blue, for: .normal)
        self.startBuildingButton.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
        self.startBuildingButton.setTitle("Start building with this template", for: .normal)
        self.startBuildingButton.titleLabel?.textAlignment = .center

        self.madeWithLoveLabel.textColor = .darkGray
        self.madeWithLoveLabel.font =  UIFont(name: "Helvetica", size: 14)
        self.madeWithLoveLabel.text = "Made with ❤️ by the Mapfit team."
        self.madeWithLoveLabel.textAlignment = .center

        self.addressLabel.text = listing.address
        self.availbilityDateLabel.text = "Availibility: \(listing.availablilityDate)"
        self.priceLabel.text = "$\(listing.price)/mo"
        self.placeDetailLabel.text = "\(listing.bedrooms) BD  |  \(listing.bathrooms) BA  |  \(listing.squarefeet) SF"
        self.mainImageView.image = listing.images[0]

        self.neighborhoodLabel.text = listing.neighborhood
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
