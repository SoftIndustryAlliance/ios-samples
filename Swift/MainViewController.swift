//
//  MainViewController.swift
// 
//
//  Created 11/9/18.
//  Copyright © 2018 Soft Industry. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseDatabase
import FBSDKLoginKit

class MainViewController: UIViewController, UITabBarControllerDelegate {
    
    private let maxCups = 6
    
    @IBOutlet weak var cirlceView: CircleView!
    @IBOutlet weak var cupsProgressLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var coffeeImageView: UIImageView!
    
    var databaseObserverHandle: DatabaseHandle = 0
    
    deinit {
        DatabaseManager.shared.removeDatabaseObserver(handle: databaseObserverHandle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        scsShowActivityView()
        databaseObserverHandle = DatabaseManager.shared.observeUserData(completion: { (userData, error) in
            self.scsHideActivityView()
            if let error = error {
                self.scsShowError(error: error)
            } else {
                self.updateUI(withData: userData)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func updateUI(withData data: UserData?) {
        if let data = data {
            let cups = data.cups
            cirlceView.progress = CGFloat(cups) / CGFloat(maxCups)
            cupsProgressLabel.text = "\(cups)/\(maxCups)"
            if cups < maxCups {
                coffeeImageView.image = UIImage(named: "coffee-item-outline")
                tipsLabel.text = NSLocalizedString("Покупайте больше кофе и получите один бесплатно!", comment: "")
            } else {
                coffeeImageView.image = UIImage(named: "coffee-item")
                tipsLabel.text = NSLocalizedString("У вас есть бесплатный кофе!", comment: "")
            }
            
            if let navigation = self.navigationController, navigation.viewControllers.count > 1 {
                navigation.popToRootViewController(animated: false)
            }
            
            self.tabBarController?.selectedIndex = 0
        } else {
            cirlceView.progress = 0.0
            cupsProgressLabel.text = nil
            tipsLabel.text = nil
        }
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToMain(_ unwindSegue: UIStoryboardSegue) {

    }

    @IBAction func signOutButtonAction(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance().signOut()
            FBSDKLoginManager().logOut()
        } catch let error {
            scsShowError(error: error)
        }
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navigation = self.navigationController, viewController == navigation, navigation.viewControllers.count > 1 {
            navigation.popToRootViewController(animated: false)
        }
    }
}
