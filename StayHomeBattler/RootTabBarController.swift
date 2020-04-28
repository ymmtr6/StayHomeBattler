//
//  RootTabBarController.swift
//  StayHomeBattler
//
//  Created by Riku Yamamoto on 2020/04/26.
//  Copyright © 2020 Riku Yamamoto. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){
        if viewController is RootTabBarDelegate {
            let vc = viewController as! RootTabBarDelegate
            vc.didSlectTab(tabBarController: self)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
