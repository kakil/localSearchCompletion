//
//  ViewController.swift
//  ITELiOSLocalSearchDemo
//
//  Created by Kitwana Akil on 5/2/17.
//  Copyright © 2017 Kitwana Akil. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var streetAddress: UITextField!
    @IBOutlet weak var cityAddress: UITextField!
    @IBOutlet weak var stateAddress: UITextField!
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var addressView: UIView!
    
    var localSearch: MKLocalSearch!
    var results: MKLocalSearchResponse! = MKLocalSearchResponse()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        addressView.addGestureRecognizer(tap)
        
        self.searchBar.delegate = self
        self.tableView.delegate = self
        
        let locationManager = CLLocationManager()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            
            //ask for authorization from the user
            locationManager.requestAlwaysAuthorization()
            
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            mapView.showsUserLocation = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways {
            
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                
                if CLLocationManager.isRangingAvailable() {
                    
                    //do stuff
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    
    //Mark - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.results.mapItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "SearchResultCell"
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: identifier)!
        
        let item: MKMapItem = results.mapItems[indexPath.row]
        
        //Pelet name = item.name!
        let streetAddress:String = item.placemark.addressDictionary!["Street"] as? String ?? ""
        let cityAddress: String = item.placemark.addressDictionary!["City"] as? String ?? ""
        let stateAddress: String = item.placemark.addressDictionary!["State"] as? String ?? ""
        let zipCodeAddress: String = item.placemark.addressDictionary!["ZIP"] as? String ?? ""
        
        //cell.textLabel?.text = "\(name), \(streetAddress)"
        cell.textLabel?.text = "\(streetAddress), \(cityAddress), \(stateAddress), \(zipCodeAddress)"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!)
        let addressText = currentCell?.textLabel?.text
        let fullAddress = addressText?.components(separatedBy: ", ")
        
        self.streetAddress.text = fullAddress?[0]
        self.cityAddress.text = fullAddress?[1]
        self.stateAddress.text = fullAddress?[2]
        self.zipCode.text = fullAddress?[3]
        print(fullAddress ?? "")
        
    }
    
    
    //Mark - Search Delegate Methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let request: MKLocalSearchRequest = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = self.mapView.region
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        localSearch = MKLocalSearch(request: request)
        
        localSearch.start { response, error in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if error != nil { return }
            
            if response?.mapItems.count == 0 { return }
            
            for item in (response?.mapItems)! {
                
                let annotation:MKPointAnnotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                annotation.subtitle = item.placemark.title
                self.mapView.addAnnotation(annotation)
            }
            
            self.results = response
            self.tableView.reloadData()
            
        }
        
        
        
    }
    
    func dismissKeyboard() {
        
        view.endEditing(true)
    }
    


}



//extension String {
//    
//    func findOccurencesOf(items: [String]) -> [String] {
//        
//        var occurences: [String] = []
//        
//        for item in items {
//            
//            if self.
//        }
//    }
//}





