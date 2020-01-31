//
//  ViewController.swift
//  ResProj
//
//  Created by Brian on 1/25/20.
//  Copyright © 2020 Brian. All rights reserved.
//

import UIKit
import GoogleMaps

class MapController: UIViewController, GMSMapViewDelegate {
    private var mapView: GMSMapView!
    private var heatmapLayer: GMUHeatmapTileLayer!
    private var marker: GMSMarker!
    private var button: UIButton!
    private var zoomInButton: UIButton!
    private var zoomOutButton: UIButton!
    
    private var latArray: [Double] = []
    private var lngArray: [Double] = []
    
    private var gradientColors = [UIColor.green, UIColor.red]
    private var gradientStartPoints = [0.2, 1.0] as [NSNumber]
    
    var markerEnabled = false;
    
    var delegate: MapControllerDelegate?
    
    override func viewDidLoad() {
        view.backgroundColor = .blue
        let camera = GMSCameraPosition.camera(withLatitude: 40.82741405, longitude: -73.87794578, zoom: 9)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        self.view = mapView

        makeMarkerLevelButton()
        makeZoomInButton()
        makeZoomOutButton()
        
        // Set heatmap options.
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 80
        heatmapLayer.opacity = 0.8
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,
                                            startPoints: gradientStartPoints,
                                            colorMapSize: 256)
        parseJSON()
        addHeatmap()
        
        // Set the heatmap to the mapview.
        heatmapLayer.map = mapView
        
        configureNavigationBar()
    }
    
    @objc func handleMenuToggle() {
        delegate?.handleMenuToggle(forMenuOption: nil)
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .red
        navigationController?.navigationBar.barStyle = .default
        
        navigationItem.title = "Heatmap"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_menu_white_3x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMenuToggle))
    }
    
    // Parse JSON data and add it to the heatmap layer.
    // Parse JSON data
    func parseJSON() {
        do {
            if let path = Bundle.main.url(forResource: "nycRecentComplaintsData", withExtension: "json", subdirectory: "Data") {
                let data = try Data(contentsOf: path)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [[String: String]]{
                    for item in object {
                        var lat : Double = 0.0
                        var lng : Double = 0.0
                        if let latString = item["Latitude"]{
                            lat = Double(latString) ?? 0.0
                            latArray.append(lat);
                        }
                        if let lngString = item["Longitude"]{
                            lng = Double(lngString) ?? 0.0
                            lngArray.append(lng);
                        }
                    }
                } else {
                    print("Could not read the JSON.")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //add it to the heatmap layer.
    func addHeatmap()  {
        var list = [GMUWeightedLatLng]()
        for (index, _) in latArray.enumerated() {
            let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(latArray[index] , lngArray[index]), intensity: 2.0)
            list.append(coords)
        }
        // Add the latlngs to the heatmap layer.
        heatmapLayer.weightedData = list
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    func makeMarkerLevelButton() {
        zoomInButton = UIButton(frame: CGRect(x: 330, y: 730, width: 35, height: 35))
        zoomInButton.backgroundColor = .white
        zoomInButton.setTitleColor(UIColor.black, for: .normal)
        zoomInButton.setTitle("*", for: .normal)
        zoomInButton.addTarget(self, action: #selector(zoomToMarker), for: .touchUpInside)
        self.mapView.addSubview((zoomInButton))
    }
    
    func makeZoomInButton() {
        zoomInButton = UIButton(frame: CGRect(x: 330, y: 770, width: 35, height: 35))
        zoomInButton.backgroundColor = .white
        zoomInButton.setTitleColor(UIColor.black, for: .normal)
        zoomInButton.setTitle("+", for: .normal)
        zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        self.mapView.addSubview((zoomInButton))
    }

    func makeZoomOutButton() {
        zoomOutButton = UIButton(frame: CGRect(x: 330, y: 810, width: 35, height: 35))
        zoomOutButton.backgroundColor = .white
        zoomOutButton.setTitleColor(UIColor.black, for: .normal)
        zoomOutButton.setTitle("-", for: .normal)
        zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        self.mapView.addSubview((zoomOutButton))
    }
    
    @objc
    func zoomToMarker() {
        mapView.animate(with: GMSCameraUpdate.zoom(to: 15))
        if(mapView.camera.zoom >= 10 && markerEnabled == false){
            for (index, _) in latArray.enumerated() {
                let position = CLLocationCoordinate2D(latitude: latArray[index], longitude: lngArray[index])
                marker = GMSMarker(position: position)
                marker.map=mapView
                markerEnabled = true;
            }
        }
    }
    
    @objc
    func zoomIn() {
        mapView.animate(with: GMSCameraUpdate.zoom(by: 1))
        if(mapView.camera.zoom >= 10 && markerEnabled == false){
            for (index, _) in latArray.enumerated() {
                let position = CLLocationCoordinate2D(latitude: latArray[index], longitude: lngArray[index])
                marker = GMSMarker(position: position)
                marker.map=mapView
                markerEnabled = true;
            }
        }
    }
    
    @objc
    func zoomOut() {
        mapView.animate(with: GMSCameraUpdate.zoom(by: -1))
        if(mapView.camera.zoom <= 10 && markerEnabled == true){
            mapView.clear()
            markerEnabled = false;
            addHeatmap()
        }
    }
}

