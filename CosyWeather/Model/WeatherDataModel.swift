//
//  weatherDataModel.swift
//  weatherApp
//
//  Created by Shalev Lazarof on 30/06/2019.
//  Copyright © 2019 Shalev Lazarof. All rights reserved.
//
import UIKit

class WeatherDataModel {
    
    var cityName : String = ""
    var weatherDescription : String = ""
    var weatherConditionNum : Int = 0
    
    var temprature : Int = 0
    var maxTemprature : Int = 0
    var minTemprature : Int = 0
    
    var weatherIconName : String = ""
    
    var date : String = ""
    
    //MARK: method that turns a condition code into the name of the weather condition image
    func updateWeatherIcon(condition: Int) -> String {
        switch (condition) {
        
        case 0...300 :
            return "tstorm1"
    
        case 301...500 :
            return "light_rain"
    
        case 501...600 :
            return "shower3"
    
        case 601...700 :
            return "snow4"
    
        case 701...771 :
            return "fog"
    
        case 772...799 :
            return "tstorm3"
    
        case 800 :
            return "sunny"
    
        case 801...804 :
            return "cloudy2"
    
        case 900...903, 905...1000  :
            return "tstorm3"
    
        case 903 :
            return "snow5"
    
        case 904 :
            return "sunny"
    
        default :
            return "dunno"
        }
    }
}
