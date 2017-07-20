//
//  CustomSearchBar.swift
//  Pods
//
//  Created by Olivia Brown on 7/20/17.
//
//

import UIKit

class CustomSearchBar: UISearchBar {

    var preferredFont: UIFont!

    init(frame: CGRect, font: UIFont, textColor: UIColor) {
        super.init(frame: frame)
        
        self.frame = frame
        preferredFont = font
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        // Find the index of the search field in the search bar subviews.
        if let index = indexOfSearchFieldInSubviews() {
            // Access the search field
            let searchField: UITextField = (subviews[0] as! UIView).subviews[index] as! UITextField
            
            // Set its frame.
            searchField.frame = CGRectMake(5.0, 5.0, frame.size.width - 10.0, frame.size.height - 10.0)
            
            // Set the font and text color of the search field.
            searchField.font = preferredFont
            
            // Set the background color of the search field.
            searchField.backgroundColor = barTintColor
        }
        
        super.drawRect(rect)
    }
}
