//
//  UIImageView+LoadFromWeb.swift
//  Sporttotal
//
//  Copyright © 2018 sporttotal.tv gmbh. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func load(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        Resource(url: url).load { (image: UIImage?) in
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
