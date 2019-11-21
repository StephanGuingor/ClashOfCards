//
//  Stack.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/14/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import Foundation
import UIKit

class Stack<T>{
    private var listStack : [T] = []
    
    func pop() -> Any {
        if listStack.count <= 0{
            print("empty stack")
            return "Empty"
        }
        let tmp = listStack.last
        listStack.removeLast()
        return tmp!
    }
    
    func push(value: T){
        listStack.append(value)
    }
    
}

class HomeStack<T> : Stack<T>{
    private var listStack : [T] = []
    
    func serve(player: Player){
        if listStack.count > 0{
            let tmp = self.pop()
            //animation to player
            player.playerStack.push(value: tmp as! Cards)
        }
    }
    func shuffle(){
            listStack.shuffle()
    }
    
    func generateCards(){
        
    }
}


class PlayerStack<T> : Stack<T>{
    private var listStack : [T] = []
    
    func grab(hStack: Stack<T>){
        let tmp = hStack.pop()
        self.push(value: tmp as! T)
        
    }

}


class Player{
    let playerStack : PlayerStack<Cards>
    
    init(playerStack: PlayerStack<Cards>){
        self.playerStack = playerStack
    }
}
