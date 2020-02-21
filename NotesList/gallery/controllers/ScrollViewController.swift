//
//  ScrollViewController.swift
//  Storyboard46
//
//  Created by ios_school on 2/18/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    var photos = [Photo]()
    var imageViews = [UIImageView]()
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self

        pageControl.numberOfPages = photos.count
        pageControl.currentPage = 0
        
        self.scrollView.bringSubviewToFront(pageControl)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for photo in photos {
            let imageView = UIImageView(image: photo.image)
            scrollView.addSubview(imageView)
            imageViews.append(imageView)
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         
        for (index, imageView) in imageViews.enumerated() {
            imageView.frame.size = scrollView.frame.size
            imageView.frame.origin.x = CGFloat(index) * scrollView.frame.width
            imageView.frame.origin.y = 0
        }
        
        let contentWidth = CGFloat(photos.count) * scrollView.frame.width
        scrollView.contentSize = CGSize(width: contentWidth, height: scrollView.frame.height)
    }

    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        let offsetX = scrollView.frame.width * CGFloat(sender.currentPage)
        scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
    }
}

extension ScrollViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentIndex = Int((scrollView.contentOffset.x / scrollView.frame.width).rounded())
        pageControl.currentPage = currentIndex
    }
}
