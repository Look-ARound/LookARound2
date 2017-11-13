//
//  DetailPageViewController.swift
//  lookaround2
//
//  Created by Angela Yu on 11/12/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class DetailPageViewController: UIPageViewController {
    var detailVCs: [DetailViewController]?

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewControllers(detailVCs, direction: .forward, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DetailPageViewController: UIPageViewControllerDataSource {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        guard let detailVCs = detailVCs else {
            return 0
        }
        return detailVCs.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = pageViewController.viewControllers?[0], let firstViewControllerIndex = detailVCs?.index(of: firstViewController as! DetailViewController) else {
            return 0
        }
        return firstViewControllerIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let detailVCs = detailVCs else {
            return nil
        }
        guard let currentPage = viewController as? DetailViewController else {
            return nil
        }
        guard let currentIndex = detailVCs.index(of: currentPage) else {
            return nil
        }
        if currentIndex > 0 {
            let previousIndex = currentIndex - 1
            let prevPage = detailVCs[previousIndex]
            return prevPage
        } else {
            return detailVCs.last
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let detailVCs = detailVCs else {
            return nil
        }
        guard let currentPage = viewController as? DetailViewController else {
            return nil
        }
        guard let currentIndex = detailVCs.index(of: currentPage) else {
            return nil
        }
        let nextIndex = currentIndex + 1
        if nextIndex < presentationCount(for: pageViewController) {
            let nextPage = detailVCs[nextIndex]
            return nextPage
        } else {
            return detailVCs.first
        }
    }
}
