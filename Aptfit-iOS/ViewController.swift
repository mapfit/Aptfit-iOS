//
//  ViewController.swift
//  Aptfit-iOS
//
//  Created by Zain N. on 4/16/18.
//  Copyright © 2018 Mapfit. All rights reserved.
//

import UIKit
import Mapfit
import CoreLocation
import TangramMap

class ViewController: UIViewController {

    var neighborhoodCollectionView: UICollectionView?
    var listingVerticalCollectionView: UICollectionView?
    var listingHorizontalCollectionView: UICollectionView?
    var listingDetailView: ListingDetailView?
    var scrollView: UIScrollView = UIScrollView()
    
    
    var layout = SnappingCollectionViewLayout()
    var toggleViewButton: UIButton?
    var mapViewIsEnabled: Bool = true
    var initialCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.73748242049333, longitude: -73.95733284034074)
    
    lazy var listings: [Listing] = [Listing]()
    
    lazy var neighborhoods: [String] = ["New York City","Chelsea"]
    lazy var mapView: MFTMapView = MFTMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDummyData()
   
        setUpNavBar()
        setUpNeighborhoodCollectionView()
        
        setUpMap()
        
        setUpHorizontalCollectionView()
        setUpVerticalCollectionView()
        
        setUpFilterToggle()
        
        //setUpListingDetailView()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setUpMap(){
        view.addSubview(mapView)
        view.sendSubview(toBack: mapView)
        mapView.mapOptions.setTheme(theme: .grayScale)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        mapView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        //mapView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        guard let neighborhoodCollectionView = self.neighborhoodCollectionView else { return }
        mapView.topAnchor.constraint(equalTo: neighborhoodCollectionView.bottomAnchor).isActive = true
        
        mapView.setZoom(zoomLevel: 14)
        mapView.setCenter(position: initialCenter)
        
        mapView.addMarker(address: "119 w 24th street ny, ny 10011") { (marker, error) in
            let image = self.textToImage(drawText: "$2,500", inImage: #imageLiteral(resourceName: "customBlueMarker"), atPoint: CGPoint(x: 0, y: 3))
            marker?.setIcon(image)
            marker?.markerOptions?.setWidth(width: 67)
            marker?.markerOptions?.setHeight(height: 50)
            let polygon = marker?.getBuildingPolygon()
            polygon?.polygonOptions?.strokeColor = "#4353FF"
            polygon?.polygonOptions?.fillColor = "#154353FF"
            polygon?.polygonOptions?.strokeWidth = 3
            
            
        }
        
        let update = TGSceneUpdate(path: "global.show_transit", value: "true")
        
        mapView.mapView.updateSceneAsync([update])
    }
    
    func setUpNavBar(){
        
        let AptfitButton = UIBarButtonItem(title: "Aptfit", style: .plain, target: self, action: #selector(leftBarItemTapped))
        let attrs = [
            NSAttributedStringKey.foregroundColor: UIColor.black,
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)
        ]
        AptfitButton.setTitleTextAttributes(attrs, for: .normal)
        let image : UIImage? = UIImage.init(named: "github")!.withRenderingMode(.alwaysOriginal)
        
        let githubButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(rightBarItemTapped))
        self.navigationItem.leftBarButtonItem = AptfitButton
        self.navigationItem.rightBarButtonItem = githubButton
        
        let navAttrs = [
            NSAttributedStringKey.foregroundColor: UIColor.darkGray,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)
        ]
        self.navigationItem.title = "Sample Apartment Finder"
        self.navigationController?.navigationBar.titleTextAttributes = navAttrs
        
    }
    
    func setUpNeighborhoodCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.neighborhoodCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        guard let neighborhoodCollectionView = self.neighborhoodCollectionView else { return }
        
        
        neighborhoodCollectionView.delegate = self
        neighborhoodCollectionView.dataSource = self
        
        
        neighborhoodCollectionView.register(NeighborhoodCollectionViewCell.self, forCellWithReuseIdentifier: "neighborhoodCell")
        
        view.addSubview(neighborhoodCollectionView)
        neighborhoodCollectionView.translatesAutoresizingMaskIntoConstraints = false

        neighborhoodCollectionView.heightAnchor.constraint(equalToConstant: 40.5).isActive = true
        neighborhoodCollectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6).isActive = true
        neighborhoodCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15).isActive = true
        neighborhoodCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        neighborhoodCollectionView.backgroundColor = UIColor.white
        
    }
    
    func setUpListingDetailView(){
        self.listingDetailView = ListingDetailView()
        guard let detailView = listingDetailView else { return }
        
        view.addSubview(detailView)
        detailView.translatesAutoresizingMaskIntoConstraints = false
        
        detailView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        detailView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
        guard let neighborhoodCollectionView = self.neighborhoodCollectionView else { return }
        detailView.topAnchor.constraint(equalTo: neighborhoodCollectionView.bottomAnchor).isActive = true
        detailView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        detailView.setUpView(listing: listings[0])
        
        
    }
    
    
    func setUpFilterToggle(){
        self.toggleViewButton = UIButton()
        guard let toggleViewButton = self.toggleViewButton else { return }
        view.addSubview(toggleViewButton)
        toggleViewButton.translatesAutoresizingMaskIntoConstraints = false

        guard let neighborhoodCollectionView = self.neighborhoodCollectionView else { return }
        toggleViewButton.leadingAnchor.constraint(equalTo: neighborhoodCollectionView.trailingAnchor, constant: 10).isActive = true
        toggleViewButton.heightAnchor.constraint(equalTo: neighborhoodCollectionView.heightAnchor).isActive = true
        toggleViewButton.centerYAnchor.constraint(equalTo: neighborhoodCollectionView.centerYAnchor).isActive = true
        toggleViewButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 10).isActive = true
        
        toggleViewButton.imageView?.contentMode = .scaleAspectFit
        toggleViewButton.setImage(#imageLiteral(resourceName: "mapView"), for: .normal)
        
        toggleViewButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
  @objc func filterButtonTapped(){
    guard let vCollectionView = self.listingVerticalCollectionView else { return }
    guard let hCollectionView = self.listingHorizontalCollectionView else { return }
    
    if mapViewIsEnabled {
        mapViewIsEnabled = false
        toggleViewButton?.setImage(#imageLiteral(resourceName: "listView"), for: .normal)
        
        UIView.animate(withDuration: 0.2) {
            self.view.sendSubview(toBack: hCollectionView)
            self.view.sendSubview(toBack: self.mapView)
            
        }
        
    } else {
        mapViewIsEnabled = true
        toggleViewButton?.setImage(#imageLiteral(resourceName: "mapView"), for: .normal)
        
        
        UIView.animate(withDuration: 0.2) {
         self.view.sendSubview(toBack: vCollectionView)
         
        }

 
    }
    
    
    }
    
    func setUpVerticalCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        listingVerticalCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        
        guard let collectionView = self.listingVerticalCollectionView else { return }
        collectionView.delegate = self
        collectionView.dataSource = self
        
         collectionView.register(ListingCollectionViewCell.self, forCellWithReuseIdentifier: "VerticalListingCell")
        
        view.addSubview(collectionView)
        view.sendSubview(toBack: collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        //collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        //collectionView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        
        guard let neighborhoodCollectionView = self.neighborhoodCollectionView else { return }
        collectionView.topAnchor.constraint(equalTo: neighborhoodCollectionView.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        collectionView.backgroundColor = UIColor.white
    }
    
    func setUpHorizontalCollectionView(){
        self.layout.scrollDirection = .horizontal
        listingHorizontalCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        
        guard let collectionView = self.listingHorizontalCollectionView else { return }
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(ListingCollectionViewCell.self, forCellWithReuseIdentifier: "VerticalListingCell")
        
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        collectionView.decelerationRate = 2
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.showsHorizontalScrollIndicator = false
        
    }
    
   @objc func leftBarItemTapped(){
        
    }
    
   @objc func rightBarItemTapped(){
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == neighborhoodCollectionView {
             return neighborhoods.count
        }else{
            return listings.count
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == neighborhoodCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "neighborhoodCell",
                                                          for: indexPath) as! NeighborhoodCollectionViewCell
            cell.neighborhood.text = neighborhoods[indexPath.row]
            cell.setUpCell()
            return cell
        }else {//if collectionView == listingVerticalCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VerticalListingCell",
                                                          for: indexPath) as! ListingCollectionViewCell
            
            
            if collectionView == listingVerticalCollectionView {
                cell.setUpCellVericalScrollingCell(listing: listings[indexPath.row])
            }else if collectionView == listingHorizontalCollectionView {
                cell.setUpCellHorizontalScrollingCell(listing: listings[indexPath.row])
            }

            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == neighborhoodCollectionView {
            return CGSize(width: self.view.frame.width * 0.2, height: 50)
        }else if collectionView == listingVerticalCollectionView {
            return CGSize(width: self.view.frame.width * 0.9, height: 280)
        }else {
            return CGSize(width: 300, height: 200)
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 18, 0, 18)
    }
    
    
}

extension ViewController {
    
    func createDummyData(){
        
        var listing = Listing(uuid: NSUUID.init(), address: "180 West 20th Street, Unit 2C", bedrooms: 1, bathrooms: 1, squarefeet: 700, price: "2,450", neighborhood: "Chelsea, Manhattan", images: [#imageLiteral(resourceName: "dummyApt")], availablilityDate: "June 14th, 2018")
        
        self.listings.append(listing)
        self.listings.append(listing)
        self.listings.append(listing)
        self.listings.append(listing)
        self.listings.append(listing)
        self.listings.append(listing)
    }
    
    func showNeighborhoods(){
        
        if let path = Bundle.main.path(forResource: "test", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["person"] as? [Any] {
                    // do stuff
                }
            } catch {
                // handle error
            }
        }
        
        
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica", size: 10)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .center
        
        let textFontAttributes = [
            NSAttributedStringKey.font: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            NSAttributedStringKey.paragraphStyle: titleParagraphStyle,
            NSAttributedStringKey.kern : 0.5
            
            ] as [NSAttributedStringKey : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}

class SnappingCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left + 18
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        
        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
        
        layoutAttributesArray?.forEach({ (layoutAttributes) in
            let itemOffset = layoutAttributes.frame.origin.x
            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
            }
        })
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}






