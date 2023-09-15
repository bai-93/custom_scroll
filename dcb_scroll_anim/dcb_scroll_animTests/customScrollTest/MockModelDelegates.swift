//
//  MockModelDelegates.swift
//  dcb_scroll_animTests
//
//  Created by baiaman apsamatov on 17/12/22.
//

import UIKit
@testable import dcb_scroll_anim

class MockModelModelViewDelegate: NSObject {
    private var sum: Int = 0
    private var flag: Bool = false
    
    func sumFlag() -> (sum:Int, flag:Bool) {
        return (self.sum, self.flag)
    }
}

extension MockModelModelViewDelegate: DelegateChangeSlider {
    func getSliderPercent(summm: Int) {
        self.sum = summm
        print("sum DELEGATE == \(summm)")
    }
    
    func getLimitError(flagError: Bool) {
        self.flag = flagError
        print("limitError DELEGATE")
    }
}
