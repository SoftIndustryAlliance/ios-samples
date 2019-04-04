//
//  MapViewController.swift
//  SevenCupClient
//
//  Created 11/9/18.
//  Copyright © 2018 Soft Industry. All rights reserved.
//

import UIKit
import GoogleMaps
import SDWebImage
import CoreLocation

class MapViewController: UIViewController {


    @IBOutlet weak var mapView: GMSMapView!
    
    var infoViewCache: [GMSMarker: ShopInfoView] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.animate(toZoom: 14.0)
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        DatabaseManager.shared.getMapPoints { (data) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let shops = data else {
                return
            }
            var bounds = GMSCoordinateBounds()
            for shop in shops {
                let coordinate = shop.coordinate
                bounds = bounds.includingCoordinate(coordinate)
                let marker = GMSMarker(position: shop.coordinate)
                marker.map = self.mapView
                marker.title = shop.name
                marker.snippet = shop.details
                marker.userData = shop
                marker.tracksInfoWindowChanges = true
            }
            self.mapView?.animate(with: .fit(bounds))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        infoViewCache.removeAll()
    }
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        var customView: UIView? = nil
        
        if let shopData = marker.userData as? ShopData {
            var infoView = infoViewCache[marker]
            if infoView == nil {
                infoView = createInfoView(withData: shopData)
                infoViewCache[marker] = infoView
        
                if let path = shopData.thumbnail, let url = URL(string: path) {
                    infoView?.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named: "coffee-item"), options: .refreshCached)
                }
            }
            customView = infoView
        }
        return customView
    }

    private func createInfoView(withData data: ShopData) -> ShopInfoView {
        let infoView = ShopInfoView(frame: CGRect(x: 0.0, y: 0.0, width: 250.0, height: 82.0))
        infoView.titleLabel.text = data.name
        infoView.subtitleLabel.text = data.details

        infoView.frame.size = infoView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        return infoView
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
            scsShowError(message: NSLocalizedString("Определение местоположения отключено в настройках", comment: ""))
        }
        return false
    }
}
