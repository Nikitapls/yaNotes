//
//  ScrollViewController.swift
//  Storyboard46
//
//  Created by ios_school on 2/18/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController {

    var photos = [Photo]()
    var imageViews = [UIImageView]()
    var startPageNumber: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for photo in photos {
             let imageView = UIImageView(image: photo.image)
             scrollView.addSubview(imageView)
             imageViews.append(imageView)
         }
        scrollView.showsHorizontalScrollIndicator = false
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        let offsetX = scrollView.frame.width * CGFloat(startPageNumber ?? 0)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
        print(scrollView.contentOffset)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         
        for (index, imageView) in imageViews.enumerated() {
            imageView.frame.size = scrollView.frame.size
            imageView.frame.origin.x = CGFloat(index) * scrollView.frame.width
            imageView.frame.origin.y = 0
            imageView.contentMode = .scaleAspectFit
        }
        
        let contentWidth = CGFloat(photos.count) * scrollView.frame.width
        scrollView.contentSize = CGSize(width: contentWidth, height: scrollView.frame.height)
        let offsetX = scrollView.frame.width * CGFloat(startPageNumber ?? 0)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
    }

}
