//
//  PlayerStack.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/26/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import Foundation

class PlayerStack : Stack<Cards>{

    func grab(hStack: Stack<Cards>){
        guard let tmp = hStack.pop() else {
            return
        }
        push(value: tmp)
    }
    
    func pop(card: Cards) -> Cards{
        
        guard let atIdx = listStack.firstIndex(of: card) else{
            print("Card was not found")
            return listStack.first!
        }
       
        let tmp = listStack[atIdx]
        listStack.remove(at: atIdx)
        return tmp
    }

}
