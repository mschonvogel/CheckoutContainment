//
//  CartViewController.swift
//  CheckoutApp
//
//  Created by Malte Schonvogel on 5/13/16.
//  Copyright © 2016 Malte GmbH. All rights reserved.
//

import UIKit

class CartViewController: UIViewController {

    var tappedCartViewHandler: (Void -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellowColor()

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedCartView)))

    }

    func tappedCartView() {
        tappedCartViewHandler?()
    }
}