//
//  CarAnnotation.swift
//  Find My Fico
//
//  Created by Dzanan Ganic on 08/09/16.
//  Copyright © 2016 fica.io. All rights reserved.
//

import Foundation
import MapKit

class CarAnnotation: MKPointAnnotation{
    var imageName: String!
    
    init(title:String, subtitle:String, imageName:String){
        super.init()
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
    }
}
