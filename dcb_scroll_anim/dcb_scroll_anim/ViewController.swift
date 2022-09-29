//
//  ViewController.swift
//  dcb_scroll_anim
//
//  Created by Baiaman Apsamatov on 18/8/21.
//

import UIKit

class ViewController: UIViewController {
    lazy var summLabel:UILabel = self.makeSummlabel()
    lazy var containerSlider = self.makeContainerSlider()
    
    var refreshScale:CADisplayLink?
    var customSliderView:CustomSliderV?

    //MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.summLabel)
        self.view.addSubview(self.containerSlider)
        
        self.autolayout()
        self.containerSlider.frame.size.width = self.view.bounds.width * 0.95
        
        self.customSliderView = CustomSliderV(localView: self.containerSlider)
//        self.customSliderView?.backgroundColor = UIColor(named: "222222")
        self.customSliderView?.frame.size = CGSize(width: self.view.bounds.width, height: self.view.bounds.height/2.0)
        self.customSliderView?.delegate = self
        self.view.addSubview(customSliderView!)
        view.backgroundColor = UIColor(named: "222222")
    }
    
    //MARK:- autolayout for label
    func autolayout() {
        NSLayoutConstraint.activate([
            
            self.summLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.summLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.summLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            
            self.containerSlider.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.containerSlider.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.containerSlider.widthAnchor.constraint(equalToConstant: self.view.bounds.width * 0.95),
            self.containerSlider.heightAnchor.constraint(equalToConstant: 175.0),
            
            self.summLabel.bottomAnchor.constraint(equalTo: self.containerSlider.topAnchor, constant: -30.0)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.customSliderView?.transform = .init(scaleX: 0.1, y: 0.1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.customSliderView?.moveCircleTo(move: 50000)
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            self.customSliderView?.transform = .identity
        }
    }
    
    //MARK:-  has released all resources
    override func viewDidDisappear(_ animated: Bool) {
        guard let refresh = self.refreshScale else {
            return
        }
        refresh.invalidate()
        print(#function)
        super.viewDidDisappear(animated)
    }
}

extension ViewController:DelegateChangeSlider {
    func getLimitError(flagError: Bool) {
        print("get litit error")
    }
    
    func getSliderPercent(summm: Int) {
        self.summLabel.text = "\(summm)"
    }
}

extension ViewController {
    
    func makeContainerSlider() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "222222")
        return view
    }
    func makeSummlabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.font = UIFont.monospacedDigitSystemFont(ofSize: 25, weight: UIFont.Weight.regular)
        view.textColor = UIColor.white
        view.textAlignment = .center
        view.text = "summ"
        return view
    }
}
