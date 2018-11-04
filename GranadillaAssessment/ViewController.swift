//
//  ViewController.swift
//  GranadillaAssessment
//
//  Created by Gabor Racz on 2018/11/04.
//  Copyright © 2018 Granadilla. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation

class ViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,MKMapViewDelegate,CLLocationManagerDelegate {

    //IBOUTLETS
    @IBOutlet weak var integer1TXT: UITextField!
    @IBOutlet weak var integer2TXT: UITextField!
    @IBOutlet weak var answerTXT: UITextField!
    @IBOutlet weak var operationPickerView: UIPickerView!
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var colourBTN: UIButton!{
        didSet{
            colourBTN.layer.borderColor = UIColor.black.cgColor
            colourBTN.layer.borderWidth = 1.5
            colourBTN.layer.cornerRadius = 5.0
        }
    }
    @IBOutlet weak var mathBTN: UIButton!{
        didSet{
            mathBTN.layer.borderColor = UIColor.black.cgColor
            mathBTN.layer.borderWidth = 1.5
            mathBTN.layer.cornerRadius = 5.0
        }
    }
    @IBOutlet weak var mapBTN: UIButton!{
        didSet{
            mapBTN.layer.borderColor = UIColor.black.cgColor
            mapBTN.layer.borderWidth = 1.5
            mapBTN.layer.cornerRadius = 5.0
        }
    }
    @IBOutlet weak var mapView: MKMapView!
    
    
    //PROPERTIES
    let locationManager = CLLocationManager()
    let arrayOfColours = [UIColor.red,UIColor.green,UIColor.blue,UIColor.brown,UIColor.yellow,UIColor.orange]
    let binaryOperation = ["Select your operation", "Addition","Subtraction","Division","Multiplication"]
    var chosenOperation:Int!
    var answer:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        operationPickerView.delegate = self
        operationPickerView.dataSource = self
        
        mapView.delegate = self
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isHidden = true
        
        hideKeyboardWhenTappedAround()
        answerTXT.isEnabled = false
        chosenOperation = 0
        
        colourBTN.addTarget(self, action: #selector(changeBackgroundColour(_button:)), for: .touchUpInside)
        mathBTN.addTarget(self, action: #selector(mathOperationControl(_button:)), for: .touchUpInside)
        mapBTN.addTarget(self, action: #selector(drawMap(_button:)), for: .touchUpInside)
    }
    
    //MARK: Control for arithmetic
    @objc private func mathOperationControl(_button:UIButton){
        
        var lhsDouble = 0.0
        var rhsDouble = 0.0
        
        if let lhs = integer1TXT.text {
            lhsDouble = Double(lhs) ?? 0.0
        }
        if let rhs = integer2TXT.text {
            rhsDouble = Double(rhs) ?? 0.0
        }
        
        switch chosenOperation {
        case 0:
            alertUser(message: "You didn't select an operation.")
        case 1:
            answer = String(lhsDouble + rhsDouble)
            answerTXT.text = answer
            operationPickerView.reloadAllComponents()
            operationPickerView.selectRow(0, inComponent: 0, animated: true)
        case 2:
            answer = String(lhsDouble - rhsDouble)
            answerTXT.text = answer
            operationPickerView.reloadAllComponents()
            operationPickerView.selectRow(0, inComponent: 0, animated: true)
        case 3:
            answer = String(lhsDouble / rhsDouble)
            answerTXT.text = answer
            operationPickerView.reloadAllComponents()
            operationPickerView.selectRow(0, inComponent: 0, animated: true)
        case 4:
            answer = String(lhsDouble * rhsDouble)
            answerTXT.text = answer
            operationPickerView.reloadAllComponents()
            operationPickerView.selectRow(0, inComponent: 0, animated: true)
        default:
            return
        }
    }
    
    //MARK: randomly change the background using arrayOfColours
    @objc func changeBackgroundColour(_button:UIButton){
        
        let selectedColour = arrayOfColours.randomElement()
        rootView.backgroundColor = selectedColour
    }
    
    //MARK: Draw the map onto screen
    @objc func drawMap(_button:UIButton){
        mapView.isHidden = false
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    //MARK: UIAlert Dialog Box
    private func alertUser(message:String){
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { handle in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: UIPickerView Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //MARK: UIPickerView Delegate
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return binaryOperation.count
    }
    //MARK: UIPickerView Delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return binaryOperation[row]
    }
    //MARK: UIPickerView Delegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.chosenOperation = row
    }
    
    //MARK: MKMapKit Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = (manager.location?.coordinate)!
        annotation.title = "You are here!"
        annotation.subtitle = "current location"
        mapView.addAnnotation(annotation)
        
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
        }
        
        manager.stopUpdatingLocation()
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

