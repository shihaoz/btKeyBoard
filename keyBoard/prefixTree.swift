//
//  prefixTree.swift
//  testWordPrediction
//
//  Created by Shihao Zhang on 11/12/16.
//  Copyright 2016 David Zhang. All rights reserved.
//

import Foundation


class Node {
    public var children: Array<Node?>
    public var parent: Node?
    public var char: Character
    public var isWord: Bool
    
    init(char: Character) {
        self.isWord = false
        self.char = char
        parent = nil
        children = Array<Node?>(repeating: nil, count: 26)   // 26 possible outlet
    }
    
}
public struct Queue<T> {
    public private(set) var elements: Array<T> = []
    public mutating func push(value: T) { elements.append(value) }
    public mutating func pop() -> T { return elements.removeFirst() }
    public var isEmpty: Bool { return elements.isEmpty }
}
extension Character{
    func toInt() -> Int {
        var ret = Int(String(self).unicodeScalars.first!.value)
        return ret
    }
}

public class prefixTree{
    private var root: Node = Node(char: "D")
    private var nodeCount = 0
    private let suggestionCount = 3
    private let base: Int = 97      // base of offset
    
    func insertWord(word: String) -> Void {
        
        var lastNode = root
        for char in word.characters{
            
            var offSet = char.toInt() - base
            if lastNode.children[offSet] == nil {
                lastNode.children[offSet] = Node(char: char)
                nodeCount += 1
            }
            lastNode = lastNode.children[offSet]!
        }
        // set isWord
        lastNode.isWord = true
    }
    
    
    public func buildTree(words: Array<String>) -> Void{
        for wd in words{
            insertWord(word: wd.lowercased())
        }
        print("\(words.count) word built, \(nodeCount) nodes")
    }
    
    func getSuggestion(target: String) -> Array<String>{
        var word = target.lowercased()
        var endNode: Node? = root
        for char in word.characters{
            var offSet = char.toInt() - base
            if endNode?.children[offSet] == nil {
                endNode = nil   // if no suggestion
                break
            }
            endNode = endNode?.children[offSet]!
        }
        if endNode == nil{  // no recommendation
            return []
        }
        var suggestWords: Array<String> = []
        var BFS: Queue<(Node, String)> = Queue()
        BFS.push(value: (endNode!, word))
        
        while !BFS.isEmpty && suggestWords.count < suggestionCount {    // BFS top-3
            var (thisNode, thisWord) = BFS.pop()
            if thisNode.isWord{
                suggestWords.append(thisWord)
            }
            for node in thisNode.children{
                if node != nil{
                    BFS.push(value: (node!, thisWord + String(node!.char)))
                }
            }
        }
        return suggestWords
    }
}


