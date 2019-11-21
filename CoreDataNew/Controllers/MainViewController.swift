//
//  MainViewController.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/20/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var playButton: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
      buttonSetUp()
        
//        self.view.addGestureRecognizer(tap)
        
    }
    @IBAction func showOptions(){
        
        let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUp_sid") as! popUpViewController
        
        self.addChild(popvc)
        
        popvc.view.frame = self.view.frame
        
        self.view.addSubview(popvc.view)
        
        popvc.didMove(toParent: self)
        
     
        //        popvc.showAnimate()
    }
    
    
 //MARK: Button SetUp
    func buttonSetUp(){
        
              playButton.layer.applySketchShadow(color: UIColor.black, alpha: 0.5, x: 0, y: 4, blur: 4, spread: 0)
              
              playButton.layer.borderWidth = 1
              
              playButton.layer.borderColor = UIColor(displayP3Red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
              
    }
//    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
