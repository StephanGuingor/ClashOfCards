////
////  LaunchScreenSVG.swift
////  CoreDataNew
////
////  Created by Stephan Guingor on 11/19/19.
////  Copyright © 2019 Stephan Guingor. All rights reserved.
////
//
//import Foundation
//import UIKit
//import Macaw
//
//
//@IBDesignable
//class MainView: MacawView{
//
//
////    @IBOutlet weak var svgView: UIView!
//
//
//   required init?(coder aDecoder: NSCoder) {
//    let button = MainView.createButton()
//        super.init(node: Group(contents: [button]), coder: aDecoder)
//    }
//
//    private static func createButton() -> Group {
//        let shape = Shape(
//            form: Rect(x: -100, y: -15, w: 200, h: 30).round(r: 5),
//            fill: LinearGradient(degree: 90, from: Color(val: 0xfcc07c), to: Color(val: 0xfc7600)),
//            stroke: Stroke(fill: Color(val: 0xff9e4f), width: 1))
//
//        let text = Text(
//            text: "Show", font: Font(name: "Serif", size: 21),
//            fill: Color.white, align: .mid, baseline: .mid,
//            place: .move(dx: 15, dy: 0))
//
//        let image = Image(src: "charts.png", w: 30, place: .move(dx: -40, dy: -15))
//
//        return Group(contents: [shape, text, image], place: .move(dx: 375 / 2, dy: 75))
//    }
//
//
//
//
//
//
//
//    override func layoutSubviews() {
//        //{(svgLayer) in
//
//
//    }
//}
////SVGParserSupportedElements
//
