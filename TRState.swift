//
//  TRState.swift
//  TextRender
//
//  Created by FN-540 on 2024/3/18.
//

import UIKit

extension UIView{
    fileprivate struct property{
        static var state:Int = 0
    }
}

extension UILabel{
    
    public var vmstate:TRState<String>{
        get{
            if let state = objc_getAssociatedObject(self, &UIView.property.state) as? TRState<String>{
                return state
            }else{
                let state = TRState(wrappedValue: "") {
                    return self.text
                } set: { t in
                    self.text = t
                }

                objc_setAssociatedObject(self, &UIView.property.state, state, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return state
            }
        }
    }
}
extension UITextField{
    
    public var vmstate:TRState<String>{
        get{
            if let state = objc_getAssociatedObject(self, &UIView.property.state) as? TRState<String>{
                return state
            }else{
                let state = TRState(wrappedValue: "") {
                    return self.text
                } set: { t in
                    self.text = t
                }

                objc_setAssociatedObject(self, &UIView.property.state, state, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return state
            }
        }
    }
}

extension UIImageView{
    
    public var vmstate:TRState<UIImage?>{
        get{
            if let state = objc_getAssociatedObject(self, &UIView.property.state) as? TRState<UIImage?>{
                return state
            }else{
                let state = TRState<UIImage?>(wrappedValue: nil) {
                    return self.image
                } set: { t in
                    self.image = t!
                }
                
                objc_setAssociatedObject(self, &UIView.property.state, state, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return state
            }
        }
    }
}

public protocol TRDynamic{
    func update()
}
@propertyWrapper
public struct TRState<T>:TRDynamic{
    public func update() {
        
    }
    
    
    public var wrappedValue: T{
        get{
            _proj.get()
        }
        set{
            _proj.set(newValue)
        }
    }
    
    private var _proj:TRBinding<T>
    
    public var projectedValue:TRBinding<T>{
        TRBinding(get: _proj.get, set: _proj.set)
    }
    public init(wrappedValue: T) {
        var value = wrappedValue
        self._proj = TRBinding<T>(get: {
            return value
        }, set: { v in
            value = v
        })
    }
    public init(wrappedValue: T, get: @escaping () -> T?, set: @escaping (T?) -> Void) {
        self._proj = TRBinding(get: {
            return get() ?? wrappedValue
        }, set: { t in
            set(t)
        })
    }
}

@propertyWrapper
public struct TRBinding<T>:TRDynamic{
    public func update() {
        
    }
    
    public var wrappedValue: T{
        get{
            self.get()
        }
        set{
            self.set(newValue)
        }
    }
    
    public var get: ()->T
    
    public var set: (T)->Void
    
    public init(get: @escaping () -> T, set: @escaping (T) -> Void) {
        self.get = get
        self.set = set
    }
    
    public var projectedView:TRBinding<T>{
        return TRBinding(get: get, set: set)
    }
}

