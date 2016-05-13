//
//  ModalCheckoutViewController.swift
//  CheckoutApp
//
//  Created by Malte Schonvogel on 5/13/16.
//  Copyright © 2016 Malte GmbH. All rights reserved.
//

import UIKit

class ModalCheckoutViewController: UIViewController {

    var tappedModalCheckoutOverlayHandler: (Void -> Void)?

    let overlayView = UIView()
    let cartVC = CartViewController()
    let checkoutVC = CheckoutViewController()

    lazy var initialConstraintsForCartVC: [NSLayoutConstraint] = {
        return [
            self.cartVC.view.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor, multiplier: 0.8),
            self.cartVC.view.heightAnchor.constraintEqualToAnchor(self.view.heightAnchor, multiplier: 0.8),
            self.cartVC.view.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor),
            self.cartVC.view.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor)
        ]
    }()

    lazy var finalConstraintsForCartVC: [NSLayoutConstraint] = {
        return [
            self.cartVC.view.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor, multiplier: 0.4),
            self.cartVC.view.heightAnchor.constraintEqualToAnchor(self.view.heightAnchor, multiplier: 0.7),
            self.cartVC.view.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor),
            self.cartVC.view.rightAnchor.constraintEqualToAnchor(self.view.centerXAnchor),
        ]
    }()

    lazy var finalConstraintsForCheckoutVC: [NSLayoutConstraint] = {
        return [
            self.checkoutVC.view.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor, multiplier: 0.4),
            self.checkoutVC.view.heightAnchor.constraintEqualToAnchor(self.view.heightAnchor, multiplier: 0.7),
            self.checkoutVC.view.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor),
            self.checkoutVC.view.leftAnchor.constraintEqualToAnchor(self.view.centerXAnchor)
        ]
    }()

    lazy var initialConstraintsForCheckoutVC: [NSLayoutConstraint] = {
        return [
            self.checkoutVC.view.leftAnchor.constraintEqualToAnchor(self.cartVC.view.leftAnchor),
            self.checkoutVC.view.rightAnchor.constraintEqualToAnchor(self.cartVC.view.rightAnchor),
            self.checkoutVC.view.topAnchor.constraintEqualToAnchor(self.cartVC.view.topAnchor),
            self.checkoutVC.view.bottomAnchor.constraintEqualToAnchor(self.cartVC.view.bottomAnchor),
        ]
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clearColor()

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedModalCheckoutOverlay)))

        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        overlayView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        overlayView.frame = view.bounds
        view.addSubview(overlayView)


        addChildViewController(cartVC)
        cartVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cartVC.view)
        cartVC.didMoveToParentViewController(self)


        checkoutVC.view.translatesAutoresizingMaskIntoConstraints = false
        checkoutVC.transitioningDelegate = self
        checkoutVC.modalPresentationStyle = .Custom


        cartVC.tappedCartViewHandler = {
            self.presentViewController(self.checkoutVC, animated: true, completion: nil)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSLayoutConstraint.activateConstraints(initialConstraintsForCartVC)
    }


    func showOnlyCartVC() {

        NSLayoutConstraint.deactivateConstraints(finalConstraintsForCartVC)
        NSLayoutConstraint.deactivateConstraints(finalConstraintsForCheckoutVC)
        NSLayoutConstraint.activateConstraints(initialConstraintsForCartVC)
    }

    func tappedModalCheckoutOverlay() {
        if presentedViewController is CheckoutViewController {
            dismissViewControllerAnimated(false, completion: nil)
        }

        tappedModalCheckoutOverlayHandler?()
    }

}

extension ModalCheckoutViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if presented is CheckoutViewController {
            return TransitionFromCartToCheckout()
        }

        return nil
    }
}



class TransitionFromCartToCheckout: NSObject, UIViewControllerAnimatedTransitioning {

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        guard let modalCheckoutVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? ModalCheckoutViewController,
            checkoutVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? CheckoutViewController,
            containerView = transitionContext.containerView() else {
                assertionFailure()
                return
        }
        
        let duration = transitionDuration(transitionContext)
        let cartVC = modalCheckoutVC.cartVC
        checkoutVC.view.alpha = 0

        containerView.addSubview(modalCheckoutVC.overlayView)
        containerView.addSubview(modalCheckoutVC.view)
        containerView.addSubview(checkoutVC.view)
        containerView.addSubview(cartVC.view)



        checkoutVC.view.frame = CGRectInset(cartVC.view.frame, cartVC.view.bounds.width / 2 * 0.1, cartVC.view.bounds.height / 2 * 0.1)

        UIView.animateWithDuration(
            duration,
            animations: {

                NSLayoutConstraint.deactivateConstraints(modalCheckoutVC.initialConstraintsForCartVC)
                NSLayoutConstraint.deactivateConstraints(modalCheckoutVC.initialConstraintsForCheckoutVC)

                NSLayoutConstraint.activateConstraints(modalCheckoutVC.finalConstraintsForCartVC)
                NSLayoutConstraint.activateConstraints(modalCheckoutVC.finalConstraintsForCheckoutVC)

                containerView.layoutIfNeeded()

                checkoutVC.view.alpha = 1
            },
            completion:  { finished in
                transitionContext.completeTransition(true)
            }
        )
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1
    }

}
