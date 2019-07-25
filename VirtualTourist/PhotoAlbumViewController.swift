//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Mazen Al Quliti on 06/07/2019.
//  Copyright © 2019 Mazen Al Quliti. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var activityBackgroundView: UIView!
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var collectionView : UICollectionView!
    
    var dataSource : [Photo]!
    var selectedPin : Pin?
    var dataController : DataController!
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 10.0,
                                             left: 10.0,
                                             bottom: 10.0,
                                             right: 10.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        dataSource = [Photo]()
        
        if (selectedPin != nil) {
            let coordinate = CLLocationCoordinate2D(latitude: selectedPin!.lat, longitude: selectedPin!.lon)
            let annotation = CustomMKPointAnnotation()
            annotation.title = "A"
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            mapView.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000), animated: true)
            updateDataSource()
        }
        activityBackgroundView.layer.cornerRadius = activityBackgroundView.bounds.width/2
        activityBackgroundView.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor
        activityBackgroundView.layer.borderWidth = 1.0
        activityBackgroundView.isHidden = true
    }
    
    func updateDataSource() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "pin", ascending: false)
        let predicate = NSPredicate(format: "pin == %@", selectedPin!)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        if let results = try? dataController.viewContext.fetch(fetchRequest) {
            dataSource = results
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CustomCell
        
        if let imageData = dataSource[indexPath.row].image {
            if let image = UIImage(data: imageData) {
                cell?.imageView.image = image
                cell?.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
                cell?.layer.cornerRadius = 5
            }
        }
        
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        deleteImage(photo: dataSource[indexPath.row])
        dataSource.remove(at: indexPath.row)
        self.collectionView.reloadData()
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
    @IBAction func fetchNewImages(_ sender: UIBarButtonItem) {
        
        activityBackgroundView.isHidden = false
        
        if let pin = selectedPin {
            
            deleteAllImage()
            dataSource = [Photo]()
            self.collectionView.reloadData()
            
            
            ConnectionManager().fetchImagesInLocation(requestUrl: FlickrAPIManager.getQueryUrl(lat: "\(pin.lat)", lon: "\(pin.lon)", page: Int.random(in: 0...Int(pin.pages)))) { (success, error) -> (Void) in
                guard success else {
                    AlertViewController(aPresenter: self).showAlert(title: "Error", body: error!.body)
                    return
                }
                
                var requestUrl : String!
                var newPhoto : Photo!
                
                for photoDetails in Model.shared!.photo {
                    requestUrl = FlickrAPIManager.gettImageUrl(farm: photoDetails.farm, serverId: photoDetails.server, photoId: photoDetails.id, secret: photoDetails.secret)
                    ConnectionManager().fetchImage(requestUrl: requestUrl, completionHandler: { (image, error) -> (Void) in
                        guard error == nil else {
                            AlertViewController(aPresenter: self).showAlert(title: "Error", body: error!.body)
                            return
                        }
                        DispatchQueue.main.async {
                            newPhoto = Photo(context: self.dataController.viewContext)
                            newPhoto.image = image?.pngData()
                            newPhoto.pin = self.selectedPin
                            self.dataSource.append(newPhoto)
                            self.collectionView.reloadData()
                            try? self.dataController.viewContext.save()
                            self.activityBackgroundView.isHidden = true
                        }
                    })
                }
                
            }
            
        }
        
    }
    
//    func addImages() {
//        var newPhoto : Photo!
//
//        for photo in dataSource {
//            newPhoto = Photo(context: self.dataController.viewContext)
//            newPhoto.image = photo..pngData()
//            newPhoto.pin = selectedPin
//        }
//
//        do {
//            try self.dataController.viewContext.save()
//        }catch {
//            print("err")
//        }
//    }
    
    func deleteAllImage() {
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "pin", ascending: false)
        let predicate = NSPredicate(format: "pin == %@", selectedPin!)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        if let results = try? dataController.viewContext.fetch(fetchRequest) {
            for obj in results {
                dataController.viewContext.delete(obj)
            }
        }
        
        try? dataController.viewContext.save()
        
    }
    
    func deleteImage(photo : Photo) {
        dataController.viewContext.delete(photo)
        try? dataController.viewContext.save()
    }
    
}

class CustomCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
