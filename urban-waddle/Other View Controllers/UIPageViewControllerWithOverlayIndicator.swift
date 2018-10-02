//
//  UIPageViewControllerWithOverlayIndicator.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 4/19/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import UIKit

class UIPageViewControllerWithOverlayIndicator: UIPageViewController {
    override func viewDidLayoutSubviews() {
        for subView in self.view.subviews {
            if subView is UIScrollView {
                subView.frame = self.view.bounds
            } else if subView is UIPageControl {
                self.view.bringSubviewToFront(subView)
            }
        }
        super.viewDidLayoutSubviews()
    }
}
