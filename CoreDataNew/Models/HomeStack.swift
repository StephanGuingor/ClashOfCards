//
//  HomeStack.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/26/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import Foundation


class HomeStack : Stack<Cards>{

    func serve(player: Player){
        if listStack.count > 0{
            guard let tmp = pop() else {
                return
            }
            //animation to player
            print(tmp.name!)
            player.playerStack.push(value: tmp)
        }
    }
    func shuffle(){
            listStack.shuffle()
    }

    func generateCards( completionHandler: @escaping () -> Void){
        
      
        
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
                    guard let resp = response else{

                       return
                   }
                //Transaction information
                print(resp)
                   do{


                       let decoder = JSONDecoder()
                        self.listStack = try decoder.decode([Cards].self, from: data)

                   }catch{
                       print("Error while decoding JSON in HomeStack")
                       return
                   }
                
               completionHandler()
                
               }
               task.resume()
    }
}
