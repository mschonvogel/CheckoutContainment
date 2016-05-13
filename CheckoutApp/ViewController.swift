//
//  ViewController.swift
//  CheckoutApp
//
//  Created by Malte Schonvogel on 5/13/16.
//  Copyright © 2016 Malte GmbH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let sourceView = UIView()
    let modalCheckoutVC = ModalCheckoutViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .redColor()
        // Do any additional setup after loading the view, typically from a nib.


        sourceView.frame = CGRect(x: view.frame.width - 200, y: view.frame.height - 100, width: 200, height: 100)
        sourceView.backgroundColor = .blackColor()
        sourceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openCartVC)))
        view.addSubview(sourceView)


        modalCheckoutVC.transitioningDelegate = self
        modalCheckoutVC.modalPresentationStyle = .Custom
        modalCheckoutVC.tappedModalCheckoutOverlayHandler = {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    func openCartVC() {
        presentViewController(modalCheckoutVC, animated: true, completion: nil)
    }
}


extension ViewController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if presented is ModalCheckoutViewController {
            return TransitionToCheckout()
        }

        return nil
    }
}


class TransitionToCheckout: NSObject, UIViewControllerAnimatedTransitioning {

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? ViewController,
        modalCheckoutVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? ModalCheckoutViewController,
        containerView = transitionContext.containerView() else {
            assertionFailure()
            return
        }

        containerView.addSubview(modalCheckoutVC.overlayView)
        modalCheckoutVC.overlayView.frame = containerView.bounds
        modalCheckoutVC.overlayView.alpha = 0

        modalCheckoutVC.view.frame = containerView.frame
        modalCheckoutVC.view.setNeedsLayout()

        let modalCheckoutVCSnapshot = modalCheckoutVC.view.snapshotViewAfterScreenUpdates(true)
        modalCheckoutVCSnapshot.frame = containerView.convertRect(fromVC.sourceView.frame, fromView: fromVC.sourceView.superview)
        containerView.addSubview(modalCheckoutVCSnapshot)


        modalCheckoutVC.view.hidden = true
        containerView.addSubview(modalCheckoutVC.view)


        let duration = transitionDuration(transitionContext)
        UIView.animateWithDuration(
            duration,
            animations: {

                modalCheckoutVC.overlayView.alpha = 1
                modalCheckoutVCSnapshot.frame = modalCheckoutVC.view.frame

            },
            completion: { finished in

                modalCheckoutVC.view.insertSubview(modalCheckoutVC.overlayView, atIndex: 0)

                modalCheckoutVC.view.hidden = false
                modalCheckoutVCSnapshot.removeFromSuperview()
                transitionContext.completeTransition(true)

            }
        )


    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {

        return 1
    }
}
