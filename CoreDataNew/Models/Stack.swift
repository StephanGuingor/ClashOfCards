//
//  Stack.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/14/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class Stack<T>{
    private var listStack : [T] = []
    
    func pop() -> T? {
        if listStack.count <= 0{
            print("empty stack")
            return nil
        }
        let tmp = listStack.last
        listStack.removeLast()
        return tmp!
    }
    
    func push(value: T){
        listStack.append(value)
    }
}

class HomeStack : Stack<Cards>{
     var listStack : [Cards] = []
    
    override func pop() -> Cards? {
        if listStack.count <= 0{
                print("empty stack")
                return nil
            }
            let tmp = listStack.last
            listStack.removeLast()
            return tmp!
        }
    
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
    
    func generateCards(){
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
               }
               task.resume()
               
    }
}


class PlayerStack : Stack<Cards>{
     var listStack : [Cards] = []
    
    override func push(value: Cards) {
        listStack.append(value)
    }
    func grab(hStack: Stack<Cards>){
        guard let tmp = hStack.pop() else {
            return
        }
        push(value: tmp)
        
    }

}


class Player{
    let playerStack : PlayerStack = PlayerStack()
    let peerID : MCPeerID
    let playerIdx:Int
    init(peerID:MCPeerID,index:Int) {
        self.peerID = peerID
        self.playerIdx = index
    }
   
}
