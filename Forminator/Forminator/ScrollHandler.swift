//
//  ScrollHandler.swift
//  Forminator
//
//  Created by Omar Hassan  on 6/21/18.
//  Copyright © 2018 Omar Hassan. All rights reserved.
//


import UIKit
import Foundation
import ObjectiveC


protocol UsesScrollHandler : AnyObject  {
    typealias doneButtonOnPress = ((_ responder:UIResponder,_ toDo : (()-> Void) ) -> Void)?
    typealias listElement = (responder: UIResponder ,onDone : doneButtonOnPress,AddNextBackArrows:Bool?)
    var scrollHandlerVar : ScrollHandler? {get set}
    func setScrollHandlerVariable() -> Void
}


class ScrollHandler:  NSObject {
    
    private typealias doneButtonOnPress = UsesScrollHandler.doneButtonOnPress
    private typealias doneClosureType = UsesScrollHandler.doneButtonOnPress
    typealias listElement = UsesScrollHandler.listElement
    
    enum TargetResponderDirection {
        case next
        case Previous
    }
    
    private struct wrapper {
        var  responder : UIResponder
        var tag : Int
        var onDone : doneClosureType
    }
    
    private var wrapperList : [wrapper]?
    private var currentSelectedWrapper : wrapper?
    private var keyboardSize : CGRect = CGRect.zero
    
    private var scrollView : UIScrollView?
    private var contentView : UIView?
    private var defaultAddNextPreviousButtons = false
    
    
    init(elementList: [listElement],scrollView : UIScrollView, contentView : UIView , addNextPreviousButtons: Bool? = true ) {
        super.init()
        wrapperList = createWrapperList(list: elementList)
        self.scrollView=scrollView
        self.contentView=contentView
        SetDelegates()
        if let addCheck = addNextPreviousButtons , addCheck{
            AddNextAndPreviousButtons()
        }
    }
    
    private func createWrapperList(list:[listElement]) -> [wrapper] {
        var resultList = [wrapper]()
        for (index,element) in list.enumerated() {
            resultList.append(wrapper(responder: element.responder, tag: index, onDone: element.onDone))
        }
        return resultList
    }
    
    public func RegisterForKeyboardNotifications() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetScrollViewInset), name: .UIKeyboardDidHide, object: nil)
    }
    
    public func UnRegisterFromKeyboardNotifications() -> Void {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func SetDelegates() -> Void {
        guard let list = wrapperList else {return}
        for element in list{
            if let txtField = element.responder as? UITextField {txtField.delegate = self}
            if let txtView = element.responder as? UITextView {txtView.delegate = self}
        }
        scrollView?.delegate=self
    }
    
    @objc func KeyboardWillShow(notification : NSNotification) -> Void {
        
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        
        self.keyboardSize = keyboardSize
        
        
        extendScrollViewBottomby(height: keyboardSize.height)
        scrollToSelected()
    }
    
    func scrollToSelected() -> Void {
        guard let control = currentSelectedWrapper?.responder as? UIControl else {return}
        let enlargedFrame = CGRect(x: control.frame.origin.x, y: control.frame.origin.y - 10 , width: control.frame.width, height: control.frame.height + 20)
        
        guard let textRect =  contentView?.window?.convert(enlargedFrame, to: scrollView) else {return}
      
        scrollView?.scrollRectToVisible(textRect, animated: true)
    }
  
    @objc private func KeyboardDoneButtonPressed() -> Void {
        hardResetView()
    }
    
    
    func getPrevious() -> UIResponder?{
        guard let currentTag = currentSelectedWrapper?.tag else {
            resetView()
            return nil
        }
        let direction : TargetResponderDirection = .Previous
        var targetTag = 0
        switch direction {
        case .next: targetTag = currentTag + 1
        case .Previous : targetTag = currentTag - 1
        }
        
        let nextResponderWrapper = wrapperList?.filter(){$0.tag == targetTag}.first
        guard nextResponderWrapper != nil else {
            resetView()
            return nil
        }
        return nextResponderWrapper?.responder
      
    }
    
    private func tryChangeControlTotTarget(direction:TargetResponderDirection) {
        guard let currentTag = currentSelectedWrapper?.tag else {
            resetView()
            return
        }
        
        var targetTag = 0
        switch direction {
        case .next: targetTag = currentTag + 1
        case .Previous : targetTag = currentTag - 1
        }
        
        let nextResponderWrapper = wrapperList?.filter(){$0.tag == targetTag}.first
        guard nextResponderWrapper != nil else {
            resetView()
            return
        }
        nextResponderWrapper?.responder.becomeFirstResponder()
        
    }
    
    
    private func canChangeControlToTargetResponder(direction:TargetResponderDirection) -> (can:Bool,responder:UIResponder?) {
        guard let currentTag = currentSelectedWrapper?.tag else {return (false,nil)}
        
        var targetTag = 0
        switch direction {
        case .next: targetTag = currentTag + 1
        case .Previous : targetTag = currentTag - 1
        }
        
        let nextResponderWrapper = wrapperList?.filter(){$0.tag == targetTag}.first
        guard nextResponderWrapper != nil else {return (false,nil)}
        return (true,nextResponderWrapper!.responder)
    }
    
    
    
    
    private func extendScrollViewBottomby(height:CGFloat) -> Void {
        scrollView?.contentInset = UIEdgeInsetsMake(0, 0, height + 10, 0)
    }
    @objc func resetScrollViewInset() -> Void {
        scrollView?.contentInset = .zero
    }
    
    
    @objc fileprivate func resetView() -> Void {
        
        scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        currentSelectedWrapper?.responder.resignFirstResponder()
    }
    
    
    fileprivate func SetCurrentResponderAndTag(responder:UIResponder) -> Void {
        let element = wrapperList?.filter(){$0.responder === responder }.first
        guard element != nil else {return}
        currentSelectedWrapper = element
    }
    
    
    
    private func AddNextAndPreviousButtons () -> Void {
        guard let list = wrapperList else {return}
        
        for element in list{
            guard element.responder.inputAccessoryView == nil else {continue}
            let toolBar = UIToolbar()
            let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let UPButton = UIBarButtonItem(image: #imageLiteral(resourceName: "upArrow"), style: .plain, target: self, action: #selector(GoToPreviousResponder))
            let downButton = UIBarButtonItem(image: #imageLiteral(resourceName: "downArrow"), style: .plain, target: self, action: #selector(GoToNextResponder))
            toolBar.setItems([UPButton, downButton,flexButton], animated: true)
            toolBar.sizeToFit()
            toolBar.isTranslucent = false
            switch element.responder {
            case is UITextField : (element.responder as! UITextField).inputAccessoryView = toolBar
            case is UITextView : (element.responder as! UITextView).inputAccessoryView = toolBar
            default: break
            }
            
        }
        
    }
    
    @objc private func GoToNextResponder() -> Void {
        tryChangeControlTotTarget(direction: .next)
    }
    @objc  private func GoToPreviousResponder() -> Void {
        tryChangeControlTotTarget(direction: .Previous)
    }
    
     
}

// public functions
extension ScrollHandler {
    public func hardResetView() -> Void {
        resetView()
    }
    
    
    
}
extension ScrollHandler : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        SetCurrentResponderAndTag(responder: textField)
        scrollToSelected()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tryChangeControlTotTarget(direction: .next)
        return false
    }
}


extension ScrollHandler : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        SetCurrentResponderAndTag(responder: textView)
    }
}







