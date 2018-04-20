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


struct LocationJson : Decodable {
    var type: String
    var features: [Features]
    
}
struct Features : Decodable {
    var type: String
    var properties: [String: String]
    var geometry: Geometry
}

struct Geometry: Decodable {
    var type : String
    var coordinates : [[[[Double]]]]
    
    
    
}

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
        showNeighborhoods()
        setUpNavBar()
        setUpNeighborhoodCollectionView()
        
        setUpMap()
        
        setUpHorizontalCollectionView()
        setUpVerticalCollectionView()
        
        setUpFilterToggle()
        checkBuildingPolygon()
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
        
//        let update = TGSceneUpdate(path: "global.show_transit", value: "true")
//
//        mapView.mapView.updateSceneAsync([update])
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
        
        if let path = Bundle.main.path(forResource: "wof_nyc", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = JSONDecoder()
                let locationJson = try! decoder.decode(LocationJson.self, from: data)
                
                for feature in locationJson.features {
                    var polygon = [CLLocationCoordinate2D]()
                    
                    for coordinate in feature.geometry.coordinates[0][0]{
                        polygon.append(getCoordinateFromDouble(coordinate))
                    }
                    
                    
                    mapView.addPolygon([polygon])
                }
                
                
        
                
            } catch {
                // handle error
            }
        }
        
        
    }
    
    func getCoordinateFromDouble(_ double: [Double]) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: double[1], longitude: double[0])
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



struct RealEstate {
var name: String
var imageUrl: String
var price: String
var address: String
var neighborhood: String
var bedroomCount: Int
var bathroomCount: Int
var area: Int
var availableDate: String
}

extension ViewController {
    
    func financialDistrict() -> [RealEstate] {
        return [
            RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$2,400", address: "65 Broadway, New York, NY 10006", neighborhood: "Financial District, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 350, availableDate: "July 14th, 2018"),
            RealEstate(name: "apt2", imageUrl:  "https://images.unsplash.com/photo-1494526585095-c41746248156?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=fd170b4cebb0b97e6337529754defcf7&auto=format&fit=crop&w=1024&q=80", price: "$3,200", address: "124 Fulton St, New York, NY 10038", neighborhood: "Financial District, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 900, availableDate: "June 16th, 2018"),
            RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1494526585095-c41746248156?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=fd170b4cebb0b97e6337529754defcf7&auto=format&fit=crop&w=1024&q=80", price: "$5,300", address: "48 Wall St, New York, NY 10005", neighborhood: "Financial District, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 900, availableDate: "June 16th, 2018"),
            RealEstate(name: "apt4", imageUrl: "https://images.unsplash.com/photo-1494526585095-c41746248156?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=fd170b4cebb0b97e6337529754defcf7&auto=format&fit=crop&w=1024&q=80", price: "$5,300", address: "16 Beaver St, New York, NY 10004", neighborhood: "Financial District, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 900, availableDate: "June 16th, 2018")
        ]
    }
    
    func greenwichVillage() -> [RealEstate] {
        return [
            RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$2,400", address: "23 E 9th St, New York, NY 10003", neighborhood: "Greenwich Village, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 350, availableDate: "July 14th, 2018"),
            RealEstate(name: "apt2", imageUrl:  "https://images.unsplash.com/photo-1494526585095-c41746248156?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=fd170b4cebb0b97e6337529754defcf7&auto=format&fit=crop&w=1024&q=80", price: "$3,200", address: "566 LaGuardia Pl, New York, NY 10012", neighborhood: "Greenwich Village, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 900, availableDate: "June 16th, 2018"),
        ]
    }
    
    func batteryParkCity() -> [RealEstate] {
        return [
            RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$2,400", address: "98 Battery Pl New York, NY 10280",
                       neighborhood: "Battery Park City, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 350, availableDate: "July 14th, 2018"),
            RealEstate(name: "apt2", imageUrl:  "https://images.unsplash.com/photo-1494526585095-c41746248156?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=fd170b4cebb0b97e6337529754defcf7&auto=format&fit=crop&w=1024&q=80", price: "$3,200", address: "380 Rector Pl, New York, NY 10280", neighborhood: "Battery Park City, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 900, availableDate: "June 16th, 2018"),
            RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1494526585095-c41746248156?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=fd170b4cebb0b97e6337529754defcf7&auto=format&fit=crop&w=1024&q=80", price: "$5,300", address: "211 North End Ave, New York, NY 10282", neighborhood: "Battery Park City, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 900, availableDate: "June 16th, 2018"),
        ]
    }
    
    func littleItaly() -> [RealEstate] {
        return [
            RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$2,400", address: "199 Hester St, New York, NY 10013",
                       neighborhood: "Little Italy, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 350, availableDate: "July 14th, 2018"),
            RealEstate(name: "apt2", imageUrl:  "https://images.unsplash.com/photo-1494526585095-c41746248156?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=fd170b4cebb0b97e6337529754defcf7&auto=format&fit=crop&w=1024&q=80", price: "$3,200", address: "197 Grand St, New York, NY 10013", neighborhood: "Little Italy, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 900, availableDate: "June 16th, 2018"),
            RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1494526585095-c41746248156?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=fd170b4cebb0b97e6337529754defcf7&auto=format&fit=crop&w=1024&q=80", price: "$5,300", address: "225 Canal St New York, NY 10013", neighborhood: "Little Italy, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 900, availableDate: "June 16th, 2018"),
        ]
    }
    
    func chelsea() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "312 W 23rd St, New York, NY 10011", neighborhood: "Chelsea, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "626 W 28th St New York, NY 10001", neighborhood: "Chelsea, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "170 8th Ave, New York, NY 10011", neighborhood: "Chelsea, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
        ]
    }
    
    func eastVillage() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "222A E 11th St New York, NY 10003", neighborhood: "East Village, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "309 E 5th St, New York, NY 10003", neighborhood: "East Village, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "709 E 6th St, New York, NY 10009", neighborhood: "East Village, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
        ]
    }
    
    
    
    func tribeca() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "60 Vestry St, New York, NY 10013", neighborhood: "Tribeca, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$1500", address: "110 Chambers St, New York, NY 10007", neighborhood: "Tribeca, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$1900", address: "65 Worth St, New York, NY 10013", neighborhood: "Tribeca, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 550, availableDate: "June 11th, 2018"),
        ]
    }
    
    func chinaTown() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "110 Centre St, New York, NY 10013", neighborhood: "Chinatown, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$1500", address: "25 Allen St, New York, NY 10002", neighborhood: "Chinatown, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018")
        ]
    }
    
    func murrayHill() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "593 3rd Ave, New York, NY 10016", neighborhood: "Murray Hill, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "248 E 35th St, New York, NY 10016", neighborhood: "Murray Hill, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "139 E 36th St, New York, NY 10016", neighborhood: "Murray Hill, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
        ]
    }
    

    func stuyesantTown() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "285 Avenue C Loop New York, NY 10009", neighborhood: "Stuyvesant Town, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "510 E 20th St, New York, NY 10009", neighborhood: "Stuyvesant Town, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                  RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "451 E 14th St, New York, NY 10009", neighborhood: "Stuyvesant Town, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
        ]
    }
    
    
    func washingtonHeights() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "720 W 173rd St New York, NY 10032", neighborhood: "Washington Heights, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "521 W 157th St New York, NY 10032", neighborhood: "Washington Heights, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "643 W 172nd St New York, NY 10032", neighborhood: "Washington Heights, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                   RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "120 Cabrini Blvd New York, NY 10032", neighborhood: "Washington Heights, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                   RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "615 W 184th St New York, NY 10032", neighborhood: "Washington Heights, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
        ]
    }
    
    func hamiltonHeights() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "610 W 145th St, New York, NY 10031", neighborhood: "Hamilton Heights, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "618 W 143rd St, New York, NY 10031", neighborhood: "Hamilton Heights, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "501 W 138th St, New York, NY 10031", neighborhood: "Hamilton Heights, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018"),
        ]
    }
    
    
    
    func centralHarlem() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "2538 Adam Clayton Powell Jr Blvd, New York, NY 10039", neighborhood: "Central Harlem, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "300 W 135th St, New York, NY 10027", neighborhood: "Central Harlem, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "8 Mt Morris Park W, New York, NY 10027", neighborhood: "Central Harlem, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018"),
        ]
    }
    
    func soho() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "34 Macdougal St, New York, NY 10012", neighborhood: "Soho, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "55 Vandam St, New York, NY 10013", neighborhood: "Soho, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "463 Broome St New York, NY 10013", neighborhood: "Soho, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018"),
        ]
    }
    
    func spanishHarlem() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "102 E 125th St, New York, NY 10035", neighborhood: "Spanish Harlem, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "315 103rd St, New York, NY 10029", neighborhood: "Spanish Harlem, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "168 E 104th St New York, NY 10029", neighborhood: "Spanish Harlem, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018"),
                  RealEstate(name: "apt4", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "351 E 119th St New York, NY 10035", neighborhood: "Spanish Harlem, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018"),
        ]
    }
    
    func morningsideHeights() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "3133 Broadway, New York, NY 10027", neighborhood: "Morningside Heights, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "536 W 113th St, New York, NY 10025", neighborhood: "Morningside Heights, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "380 Riverside Dr New York, NY 10025", neighborhood: "Morningside Heights, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018")
        ]
    }
    
    func hellsKitchen() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "519 W 36th St, New York, NY 10018", neighborhood: "Hell's Kitchen, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "365 W 36th St, New York, NY 10018", neighborhood: "Hell's Kitchen, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "353 W 39th St, New York, NY 10025", neighborhood: "Hell's Kitchen, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018")
        ]
    }
    
    func flatironDistrict() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "44 W 24th St, New York, NY 10010", neighborhood: "Flatiron District, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "21 E 22nd St, New York, NY 10010", neighborhood: "Flatiron District, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "48 W 21st St, New York, NY 10010", neighborhood: "Flatiron District, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018")
        ]
    }
    
    func midtownWest() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "532 W 43rd St, New York, NY 10036", neighborhood: "Midtown West, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "428 W 44th St, New York, NY 10036", neighborhood: "Midtown West, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "353 W 48th St, New York, NY 10036", neighborhood: "Midtown West, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018"),
               RealEstate(name: "apt4", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "1023 6th Ave, New York, NY 10018", neighborhood: "Midtown West, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018"),
               RealEstate(name: "apt5", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "145 W 46th St, New York, NY 10036", neighborhood: "Midtown West, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018")
        ]
    }
    
    func midtownEast() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "111 E 56th St, New York, NY 10022", neighborhood: "Midtown East, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$1500", address: "253 E 50th St, New York, NY 10022", neighborhood: "Midtown East, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$1900", address: "120 E 47th St, New York, NY 10017", neighborhood: "Midtown East, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 550, availableDate: "June 11th, 2018"),
        ]
    }
    
    func lowerEastside() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "74-100 Ridge St, New York, NY 10002", neighborhood: "Lower East Side, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$1500", address: "67-1 Norfolk St, New York, NY 10002", neighborhood: "Lower East Side, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$1900", address: "350 Grand St, New York, NY 10002", neighborhood: "Lower East Side, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 550, availableDate: "June 11th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$1900", address: "219-229 Clinton St, New York, NY 10002", neighborhood: "Lower East Side, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 550, availableDate: "June 11th, 2018")
        ]
    }
    
    func gramercy() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "179 3rd Ave, New York, NY 10003", neighborhood: "Gramercy, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$1500", address: "152 E 21st St, New York, NY 10010", neighborhood: "Gramercy, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018")
        ]
    }
    
    func upperWestSide() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "215 W 106th St, New York, NY 10025", neighborhood: "Noho, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "328 W 86th St New York, NY 10024", neighborhood: "Upper West Side, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "835 Columbus Ave, New York, NY 10025", neighborhood: "Upper West Side, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "261 W 70th St, New York, NY 10023", neighborhood: "Upper West Side, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "216 W 62nd St, New York, NY 10023", neighborhood: "Upper West Side, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018"),
                  RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "433 W 66th St, New York, NY 10069", neighborhood: "Upper West Side, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018"),
        ]
    }
    
    func westVillage() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "173 Christopher St, New York, NY 10014", neighborhood: "West Village, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "55 Bethune St, New York, NY 10014", neighborhood: "West Village, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "220 W 13th St, New York, NY 10012", neighborhood: "West Village, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018"),
        ]
    }

    func noho() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "430 Lafayette St, New York, NY 10003", neighborhood: "Noho, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "9 Great Jones St, New York, NY 10003", neighborhood: "Noho, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "7 Bleecker St, New York, NY 10012", neighborhood: "Noho, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 750, availableDate: "June 11th, 2018"),
        ]
    }
    
    func twoBridges() -> [RealEstate] {
        return [ RealEstate(name: "apt1", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$3400", address: "34 Monroe St, New York, NY 10002", neighborhood: "Two Bridges, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 13th, 2018"),
                 RealEstate(name: "apt2", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$1500", address: "51 Monroe St, New York, NY 10002", neighborhood: "Two Bridges, Manhattan", bedroomCount: 3, bathroomCount: 2, area: 350, availableDate: "June 16th, 2018"),
                 RealEstate(name: "apt3", imageUrl: "https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=91b874ce453385d8867cc98ee582fee3&auto=format&fit=crop&w=1024&q=80", price: "$1900", address: "89 Catherine St, New York, NY 10038", neighborhood: "Two Bridges, Manhattan", bedroomCount: 2, bathroomCount: 1, area: 550, availableDate: "June 11th, 2018"),
        ]
    }
    

    func checkBuildingPolygon(){
        
        self.mapView.addMarker(address: "89 Catherine St, New York, NY 10038") { (marker, error) in
            
        }
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








