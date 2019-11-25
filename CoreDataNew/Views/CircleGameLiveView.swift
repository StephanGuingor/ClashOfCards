//
//  CircleGameLiveView.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/24/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import Foundation
import Macaw


///Custom view. that displays a circle, if you eant to use it in landscape you'll have to re assign the node. 
class CircleView: MacawView {
    //default
  var shape = Shape(form: Circle(cx: 20 , cy: 20, r: 10),
                    fill: LinearGradient(degree: 90, from: Color.red, to: Color.rgb(r: 230, g: 0, b: 0)),
                    stroke: Stroke(fill: Color.white, width: 2))
  
    required init?(coder aDecoder: NSCoder) {
        

        super.init(node: shape, coder: aDecoder)
        
        //I should either modify this value when its rotated or not let user rotate device
        self.shape.form = Circle(cx: Double(self.bounds.height) * 0.5, cy: Double(self.bounds.height)*0.5, r: Double(self.bounds.height) * 0.25)
        
        backgroundColor = UIColor.clear
        
    }
     
}
