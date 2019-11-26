//
//  Stack.swift
//  CoreDataNew
//
//  Created by Stephan Guingor on 11/14/19.
//  Copyright © 2019 Stephan Guingor. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Stack<T>{
    var listStack : [T] = []
    
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

