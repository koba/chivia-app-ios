//
//  MapViewDelegate.swift
//  Chivia
//
//  Created by Agustín Rodríguez on 10/23/17.
//  Copyright © 2017 Agustín Rodríguez. All rights reserved.
//

import MapboxDirections
import MapboxNavigation

class HomeMapView : UIView, MGLMapViewDelegate {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var zeroHeightConstraint: NSLayoutConstraint!
    
    private var mapViewHasLocatedUser = false
    private var mapViewDestinationAnnotation: MGLPointAnnotation?
    private var mapViewRouteAnnotation: MGLPolyline?
    
    private var destination: CLLocationCoordinate2D?
    private var route: Route?
    
    public var delegate: HomeMapViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("HomeMapView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.styleURL = MGLStyle.lightStyleURL()
        mapView.zoomLevel = 14
        
        loadStands()
    }
    
    func mapView(_ _: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ _: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 1
    }
    
    func mapView(_ _: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        if (!mapViewHasLocatedUser) {
            mapView.setCenter(mapView.userLocation!.coordinate, animated: false)
            mapViewHasLocatedUser = true
        }
    }
    
    func mapView(_ _: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 3
    }
    
    private func loadStands() {
        ChiviaService
            .singleton()
            .stand
            .get()
            .then {
                $0.forEach({ stand in
                    let annotation = MGLPointAnnotation()
                    annotation.coordinate = stand.coordinate
                    annotation.title = stand.name
                    annotation.subtitle = "\(stand.size) plazas"
                    self.mapView.addAnnotation(annotation)
                })
        }
    }
    
    public func setDestination(destination: CLLocationCoordinate2D) {
        self.destination = destination
        
        if mapViewDestinationAnnotation == nil {
            mapViewDestinationAnnotation = MGLPointAnnotation()
            mapViewDestinationAnnotation!.coordinate = destination
            mapView.addAnnotation(mapViewDestinationAnnotation!)
        }
        else {
            mapViewDestinationAnnotation?.coordinate = destination
        }
        
        mapView.setCamera(mapView.cameraThatFitsCoordinateBounds(MGLCoordinateBounds(sw: mapView.userLocation!.coordinate, ne: destination), edgePadding: UIEdgeInsets(top: 86, left: 32, bottom: 248, right: 32)), animated: true)
        
        ChiviaService
            .singleton()
            .route
            .get(from: mapView.userLocation!.coordinate, to: destination)
            .then {
                self.setRoute(route: $0)
            }
    }
    
    private func setRoute(route: Route) {
        self.route = route
        
        if mapViewRouteAnnotation == nil {
            mapViewRouteAnnotation = MGLPolyline(coordinates: route.geometry, count: UInt(route.geometry.count))
            mapView.addAnnotation(mapViewRouteAnnotation!)
        }
        else {
            mapViewRouteAnnotation?.setCoordinates(UnsafeMutablePointer(mutating: route.geometry), count: UInt(route.geometry.count))
        }
        
        zeroHeightConstraint.isActive = false
        
        delegate?.homeMapView(homeMapView: self, routeDetected: route)
    }
    
    @IBAction func navigateButton(_ sender: UIButton) {
        if route != nil {
            let routeOptions = RouteOptions(waypoints: route!.waypoints)
            routeOptions.includesSteps = true
            routeOptions.routeShapeResolution = .full
            
            Directions.shared.calculate(routeOptions) { (waypoints, routes, error) in
                guard let route = routes?.first else { return }
                
                self.inputViewController?.present(NavigationViewController(for: route), animated: true, completion: nil)
            }
        }
    }
}