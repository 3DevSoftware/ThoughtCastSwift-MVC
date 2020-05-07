//
//  OnboardingViewController.swift
//  NeoPenDemo
//
//  Created by Trevor Walker on 1/26/20.
//  Copyright © 2020 Trevor Walker. All rights reserved.
//

import UIKit
import FirebaseAuth

class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    lazy var views: [UIViewController] = {
        return [newVC("step1"), newVC("step2"), newVC("step3"), newVC("step4")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        // Do any additional setup after loading the view.
        if let vc1 = views.first {
            self.setViewControllers([vc1], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        if Auth.auth().currentUser != nil {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func newVC(_ viewController: String) -> UIViewController {
        return UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = views.firstIndex(of: viewController) else {return nil}
        let previous = viewControllerIndex - 1
        guard previous >= 0, views.count > previous else {return nil}
        return views[previous]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = views.firstIndex(of: viewController) else {return nil}
        let next = viewControllerIndex + 1
        guard next != views.count else {
            performSegue(withIdentifier: "showLogin", sender: nil)
            return nil
        }
        guard views.count > next else {return nil}
        return views[next]
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NJPenCommManager.sharedInstance()!.btStart()
        NJPenCommManager.sharedInstance()!.btStop()
        
        guard let destination = segue.destination as? LoginViewController else {return}
        destination.sender = self
    }
}
