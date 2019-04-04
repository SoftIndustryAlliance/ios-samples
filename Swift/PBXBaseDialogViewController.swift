//
//  PBXBaseDialogViewController.swift
//
//  Copyright © 2017 Soft Industry. All rights reserved.
//

import UIKit

enum PBXDialogViewButtonsLayout {
    case left, symmetrically, right
}

protocol PBXDialogViewLayoutDelegate {
    var dialogViewContentHeight: CGFloat { get set }
}

class PBXBaseDialogViewController: UIViewController, PBXDialogViewLayoutDelegate {
    
    class func present(by controller: UIViewController, onSave: @escaping () -> Void ) {
        let dummyDecoder = NSKeyedArchiver(forWritingWith: NSMutableData(length: 0)!)
        dummyDecoder.finishEncoding()
        if let newController = self.init(coder: dummyDecoder) {
            newController.onSave = onSave
            controller.present(newController, animated: true, completion: nil)
        }
    }
    
    var caption: String?
    var buttonsLayout: PBXDialogViewButtonsLayout = .right
    var onSave: () -> Void = {}
    var afterClose: (() -> Void)?
    var dismissAnimated = true
    var isDataValid: Bool {
        return true
    }
    
    var dialogViewContentHeight: CGFloat = 0.0 {
        didSet {
            if dialogViewContentHeight != oldValue {
                if let tableView = containerView.subviews.first as? UITableView {
                    let maxHeightForContainerView = UIScreen.main.bounds.height - 2 * 16.0 - containerView.frame.origin.y - buttonsView.bounds.height - 8.0
                    let separatorLineHeight: CGFloat = 1.0
                    containerViewHeightConstraint.constant = max(min(tableView.contentSize.height - separatorLineHeight, maxHeightForContainerView), 0)
                    tableView.contentInset = UIEdgeInsets(top: tableView.contentInset.top, left: tableView.contentInset.left,
                                                          bottom: tableView.contentInset.bottom - separatorLineHeight, right: tableView.contentInset.right)
                    tableView.bounces = (containerViewHeightConstraint.constant == maxHeightForContainerView)
                } else {
                    containerViewHeightConstraint.constant = dialogViewContentHeight
                }
                dialogView.layoutIfNeeded()
            }
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewContentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var spaceBetweenButtonsConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightButtonEdgeConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftButton: PBXRoundedCornerButton!
    @IBOutlet weak var rightButton: PBXRoundedCornerButton!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    convenience init() {
        let dummyDecoder = NSKeyedArchiver(forWritingWith: NSMutableData(length: 0)!)
        dummyDecoder.finishEncoding()
        self.init(coder: dummyDecoder)
    }
    
    required init!(coder aDecoder: NSCoder) {
        super.init(nibName: "PBXBaseDialogViewController", bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.bounces = false
        titleLabel.text = caption
        
        if buttonsLayout == .symmetrically {
            spaceBetweenButtonsConstraint.isActive = false
            let horizontalOffset: CGFloat = 24.0
            NSLayoutConstraint(item: leftButton, attribute: .leading, relatedBy: .equal,
                               toItem: buttonsView, attribute: .leading, multiplier: 1.0, constant: horizontalOffset).isActive = true
            rightButtonEdgeConstraint.constant = horizontalOffset
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardWillChangeFrame),
                                               name: Notification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        updateScrollViewContentHeight()
        super.viewWillLayoutSubviews()
    }
    
    func onKeyboardWillChangeFrame(notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let windowFrame = self.view.window?.frame {
            let keyboardSize = CGSize(width: keyboardFrame.width, height: windowFrame.height - keyboardFrame.origin.y)
            let bottomSpaceConstant = keyboardSize.height + 4.0
            if bottomSpaceConstraint.constant != bottomSpaceConstant {
                bottomSpaceConstraint.constant = bottomSpaceConstant
                updateScrollViewContentHeight()
            }
        }
    }
    
    func updateScrollViewContentHeight() {
        let newScrollViewHeight = max(self.view.bounds.height - scrollView.frame.origin.y - bottomSpaceConstraint.constant, dialogView.bounds.height)
        if scrollViewContentHeightConstraint.constant != newScrollViewHeight {
            scrollViewContentHeightConstraint.constant = newScrollViewHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func saveSettings() {
        if isDataValid {
            onSave()
            self.dismiss(animated: dismissAnimated, completion: afterClose)
        }
    }
    
    @IBAction func cancelEdit() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func outspaceTapped(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: dialogView)
        if !dialogView.point(inside: touchLocation, with: nil) {
            cancelEdit()
        }
    }

}
