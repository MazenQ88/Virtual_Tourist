//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Mazen Al Quliti on 03/07/2019.
//  Copyright © 2019 Mazen Al Quliti. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView : MKMapView!
    var annotations : [Pin]?
    var selectedPinAnnotation : CustomMKPointAnnotation?
    var dataController : DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "lat", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let results = try? dataController.viewContext.fetch(fetchRequest) {
            annotations = results
        }
        
        loadAnnotations()
        
    }

    func loadAnnotations() {
        if let _ = annotations {
            for object : Pin in annotations! {
                let coordinate = CLLocationCoordinate2D(latitude: object.lat, longitude: object.lon)
                let annotation = CustomMKPointAnnotation()
                annotation.title = "A"
                annotation.coordinate = coordinate
                annotation.pin = object
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func addPin(lat : Double, lon: Double, pages: Int) -> Pin{
        let pin = Pin(context: dataController.viewContext)
        pin.lat = lat
        pin.lon = lon
        pin.pages = Int16(pages)
        try? dataController.viewContext.save()
        annotations?.append(pin)
        return pin
    }
    
    func removePin(index: Int) {
        if let _ = annotations {
            let pin = annotations![index]
            dataController.viewContext.delete(pin)
            try? dataController.viewContext.save()
            annotations!.remove(at: index)
        }
    }
    
    @IBAction func didLongPress(_ recognizer: UILongPressGestureRecognizer) {
        
        if recognizer.state == .began {
            let pointInView = recognizer.location(in: self.mapView)
            let coordinate = mapView.convert(pointInView, toCoordinateFrom: self.mapView)
            
            ConnectionManager().fetchImagesInLocation(requestUrl: FlickrAPIManager.getQueryUrl(lat: "\(coordinate.latitude)", lon: "\(coordinate.longitude)")) { (success, error) -> (Void) in
                guard success else {
                    AlertViewController(aPresenter: self).showAlert(title: "Error", body: error!.body)
                    return
                }
                
                var pin : Pin?
                DispatchQueue.main.async {
                    pin = self.addPin(lat: coordinate.latitude, lon: coordinate.longitude, pages: Model.shared!.pages)
                    let annotation = CustomMKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "A"
                    annotation.pin = pin
                    self.mapView.addAnnotation(annotation)
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
                        newPhoto = Photo(context: self.dataController.viewContext)
                        newPhoto.image = image?.pngData()
                        newPhoto.pin = pin
                        try? self.dataController.viewContext.save()
                    })
                }
            }
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        selectedPinAnnotation = view.annotation as! CustomMKPointAnnotation
        performSegue(withIdentifier: "showAlbum", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? PhotoAlbumViewController {
            if (selectedPinAnnotation != nil) {
                dest.selectedPin = selectedPinAnnotation?.pin
                dest.dataController = dataController
            }
        }
    }
    
}

class CustomMKPointAnnotation : MKPointAnnotation {
    var pin : Pin?
}

