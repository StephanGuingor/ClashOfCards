//
//  ViewController.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/11/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var imageCool: AnimatedCard!
    
    @IBOutlet weak var tableView: UITableView!
    
    var cards: [Cards]?
    var cardsFetched = [CardEntity]()
    
    
    //TEST
    var cardIndex = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imageCool.startingPosition(viewC: self)
       
        tableView.layer.zPosition = -3
        imageCool.layer.zPosition = -1
       
        
        
checkFunctionToLoad()
        
    }
    
//ANIMATION
    
    @IBAction func animateImage(_ sender: Any) {
    
        imageCool.serve(indexCard: &cardIndex, viewC: self)
        cardIndex += 1
        
    }
    
    func jsonDecryption(){
        let url = URL(string: "http://www.clashapi.xyz/api/cards")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error{
                print(error.localizedDescription)
                return
            }
            guard let data = data else{
                print("Error while loading")
                return
            }
            guard let resp = response as? URLResponse else{
                print("err")
                return
            }
            do{
                
                
                let decoder = JSONDecoder()
                self.cards = try decoder.decode([Cards].self, from: data)
                self.iterateOverCards(cards: self.cards!)
            }catch{
                print("error while pasing json")
                return
            }
        }
        task.resume()
        
    }
    func iterateOverCards(cards: [Cards]){
        DispatchQueue.main.async {
            let request = NSFetchRequest<CardEntity>(entityName: "CardEntity")
            for card in cards{
                do{
                    let entity = CardEntity(context: PersistanceService.context)
                    entity.elixirCost = Int32(exactly:
                        card.elixirCost!)!
                    entity.idName = card.idName!
                    entity.imageUrl = try Data(contentsOf: URL(string: card.imageUrl)!)
                    entity.name = card.name!
                    entity.rarity = card.rarity!
                    entity.type = card.type!
                } catch {
                    print(error.localizedDescription)
                }
                
                do{
                    self.cardsFetched = try PersistanceService.context.fetch(request)
                    self.cardsFetched.sort { (first, second) -> Bool in
                        return first.idName! < second.idName!
                    }
                    self.tableView.reloadData()
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    //puedes tener un sql local para guardar la informacion en el dispositivo
    func checkFunctionToLoad(){
        let request = NSFetchRequest<CardEntity>(entityName: "CardEntity")
        
            do {
                cardsFetched = try PersistanceService.context.fetch(request)
                cardsFetched.sort { (first, second) -> Bool in
                    return first.idName! < second.idName!
                }
                if cardsFetched.count > 0{
                        tableView.reloadData()
                        return
                        
                    }else{
                        jsonDecryption()
                      
                }
            } catch  {
                print(error.localizedDescription)
            }
            
        
            
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardsFetched.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as! TableViewCell
        cell.layer.zPosition = -2
        cell.imView.image = UIImage(data: cardsFetched[indexPath.row].imageUrl!)
        
        imageCool.image = UIImage(data: cardsFetched[indexPath.row].imageUrl!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}
