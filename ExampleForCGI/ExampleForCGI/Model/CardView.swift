//
//  CardView.swift
//  ExampleForCGI
//
//  Created by Fizza Hagverdizade on 19.03.22.
//

import SwiftUI

// Sample Card

struct CardView: Identifiable {
    
    var id = UUID().uuidString
    var cardColor: Color
    var date: String = ""
    var title: String
}
