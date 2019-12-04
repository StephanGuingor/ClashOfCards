//
//  EndGameViewController.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 12/4/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import UIKit

class EndGameViewController: UIViewController {

    @IBOutlet weak var lastView: UIView!
    
    @IBOutlet weak var winOrLoseLabel: UILabel!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var quitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        shadowSetup()
    }
    

    @IBAction func quitButton(_ sender: Any) {
        self.performSegue(withIdentifier: "restartSID", sender: self)
    }
    
    func shadowSetup(){
        backView.layer.applySketchShadow(color: UIColor.black, alpha: 0.5, x: 0, y: 4, blur: 4, spread: 0)
        
        backView.layer.borderWidth = 1
        
        backView.layer.borderColor = UIColor(displayP3Red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        
        
        
        
        
        
        quitButton.layer.applySketchShadow(color: UIColor.black, alpha: 0.5, x: 0, y: 4, blur: 4, spread: 0)
        
        quitButton.layer.borderWidth = 1
        
        quitButton.layer.borderColor = UIColor(displayP3Red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        
        showAnimate()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate()
    {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        })
    }
    
    //MARK:SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "restartSID"{
        print("going back")
        //FIXME:SOME RESTART LOGIC 
    }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
