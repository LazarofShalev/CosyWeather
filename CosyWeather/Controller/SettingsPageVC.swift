//
//  SettingsPageVC.swift
//  weatherApp
//
//  Created by Shalev Lazarof on 30/06/2019.
//  Copyright © 2019 Shalev Lazarof. All rights reserved.
//

import UIKit

protocol changeCityDelegate {
    func userEnterCityName(city : String)
}

class SettingsPageVC: UIViewController {
    @IBOutlet weak var CityNameTextField: UITextField!
    
    var delegate : changeCityDelegate? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Lower keyboared once pressed outside
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }   
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getWeatherButtonPressed(_ sender: Any) {
        let cityName = CityNameTextField.text!
        delegate?.userEnterCityName(city: cityName)
        dismiss(animated: true, completion: nil)
    }
    
}

