//
//  LocationViewController.swift
//  MyDocMap
//
//  Created by Nithin Chakravarthy on 5/27/16.
//  Copyright © 2016 Nithin Chakravarthy. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    var docType:String = ""
    @IBOutlet weak var searchType: UITextField!
    @IBAction func doctorType(sender: UITextField) {
        var docType = sender.text!
    }
    
    
    @IBOutlet weak var currentAddress: UILabel!
    
    @IBOutlet weak var currentMap: MKMapView!
    
    var selectedPin:MKPlacemark? = nil
    var geoCoder: CLGeocoder!
    var locationManager: CLLocationManager!
    var previousAddress: String!
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    let searchRadius: CLLocationDistance = 5000
    var locations: CLLocation!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
        geoCoder = CLGeocoder()
        self.currentMap.delegate = self
        self.searchType.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func refreshLocation(sender: UIButton) {
        viewDidLoad()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.first!
        self.currentMap.centerCoordinate = location.coordinate
        let reg = MKCoordinateRegionMakeWithDistance(location.coordinate, 1500, 1500)
        self.currentMap.setRegion(reg, animated: true)
        geoCode(location)

        let latitude: Double = location.coordinate.latitude
        let longitude: Double = location.coordinate.longitude
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        let request = MKLocalSearchRequest()
        let doctorSearchType = docType
        if(doctorSearchType == ""){
            request.naturalLanguageQuery = "Hospital"
        }
        else {
            request.naturalLanguageQuery = docType
        }
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        request.region = MKCoordinateRegion(center: initialLocation.coordinate, span: span)
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler({(response: MKLocalSearchResponse?, error: NSError?) in
        for item in response!.mapItems {
            print(item.name)
            self.addPinToMapView(item.name!, latitude: item.placemark.location!.coordinate.latitude, longitude: item.placemark.location!.coordinate.longitude)
         }
         })
         //locationManager.stopUpdatingLocation()
         let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, searchRadius * 3.0, searchRadius * 3.0)
         currentMap.setRegion(coordinateRegion, animated: true)
    }

    func addPinToMapView(title: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let anotation = MKPointAnnotation()
        anotation.coordinate = location
        anotation.title = "\(title)"
        anotation.subtitle = "www.google.com/\(title)"
        currentMap.addAnnotation(anotation)
    }
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        geoCode(location)
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    
    func geoCode(location : CLLocation!){
        geoCoder.cancelGeocode()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (data, error) -> Void in
            guard let placeMarks = data as [CLPlacemark]! else {
                return
            }
            let loc: CLPlacemark = placeMarks[0]
            let addressDict : [NSString:NSObject] = loc.addressDictionary as! [NSString: NSObject]
            let addrList = addressDict["FormattedAddressLines"] as! [String]
            let joiner = ","
            let address = addrList.joinWithSeparator(joiner)
            print(address)
            self.currentAddress.text = address
            self.previousAddress = address
        })
    }
}
