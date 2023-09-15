//
//  dcb_scroll_animTests.swift
//  dcb_scroll_animTests
//
//  Created by Baiaman Apsamatov on 18/8/21.
//

import XCTest
@testable import dcb_scroll_anim

class dcb_scroll_animTests: XCTestCase {
    
    var sliderView: CustomSliderV!
    var modelView: MockModelModelViewDelegate!
    var localView: UIView!
    
    override func setUp() {
        super.setUp()
        self.localView = UIView(frame: .init(x: 0.0, y: 0.0, width: 500.0, height: 100.0))
        self.sliderView = CustomSliderV(localView: self.localView)
        self.modelView = MockModelModelViewDelegate()
        self.sliderView.delegate = self.modelView
    }

    override func tearDown() {
        super.tearDown()
        self.sliderView = nil
        self.modelView = nil
        self.localView = nil
    }
    
    func test_sumNativeSlider() {
        
        XCTAssertNotNil(self.sliderView.delegate)
        XCTAssertIdentical(self.sliderView.delegate, self.modelView)
        
        XCTAssertEqual(self.sliderView.nativeSlider.minimumValue, 3000)
        XCTAssertEqual(self.sliderView.nativeSlider.maximumValue, 100000)
        
        self.sliderView.nativeSlider.setValue(50000, animated: false)
        
        self.sliderView.moveCircleTo(move: 40000)
        XCTAssertEqual(self.sliderView.nativeSlider.value, 40000)
        
        self.sliderView.sliderChangeValue(sender: self.sliderView.nativeSlider)
        
        XCTAssertEqual(self.modelView.sumFlag().sum, 40000)
        
        self.sliderView.nativeSlider.setValue(200000, animated: false)
        self.sliderView.sliderChangeValue(sender: self.sliderView.nativeSlider)
        XCTAssertEqual(self.sliderView.nativeSlider.value, 100000)
        XCTAssertEqual(self.modelView.sumFlag().sum, 100000)
        
        self.sliderView.nativeSlider.setValue(-100, animated: false)
        self.sliderView.sliderChangeValue(sender: self.sliderView.nativeSlider)
        XCTAssertEqual(self.sliderView.nativeSlider.value, 3000)
        XCTAssertEqual(self.modelView.sumFlag().sum, 3000)
        
    }
    
    func test_gradient() {
        XCTAssertNotNil(self.sliderView.gradient.colors)
        XCTAssertNotNil(self.sliderView.gradient.actions)
    }
    
    func test_formatingNumber() {
        XCTAssertNoThrow(self.sliderView.formatingNumber(number: Int(45.6)))

        XCTAssertEqual(self.sliderView.formatingNumber(number: 2000).count, 4)
        XCTAssertEqual(self.sliderView.formatingNumber(number: 3000), "3 000")
        XCTAssertEqual(self.sliderView.formatingNumber(number: 0), "0")
        XCTAssertEqual(self.sliderView.formatingNumber(number: -100), "-100")
        XCTAssertEqual(self.sliderView.formatingNumber(number: 11000), "11 000")
        XCTAssertEqual(self.sliderView.formatingNumber(number: 50000), "50 000")
        XCTAssertEqual(self.sliderView.formatingNumber(number: 100000), "100 000")
        XCTAssertNotEqual(self.sliderView.formatingNumber(number: 101000),"101 000")
    }
}
