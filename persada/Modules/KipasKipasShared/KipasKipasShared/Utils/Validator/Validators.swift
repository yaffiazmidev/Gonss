import Foundation

public enum Validators {}

extension Validators {
    
    public struct CombineTwo<A, B>: Validator where A: Validator, B: Validator {
        
        let a: A
        let b: B
        
        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }
        
        public func validate(_ value: String) -> ValidationResult {
            let a = a.validate(value)
            let b = b.validate(value)
            
            guard a.error == nil else { return a }
            guard b.error == nil else { return b }
            
            return .init(value: value)
        }
    }
}

extension Validators {
    
    public struct CombineThree<A, B, C>: Validator where A: Validator, B: Validator, C: Validator {
        
        private let a: A
        private let b: B
        private let c: C
        
        public init(_ a: A, _ b: B, _ c: C) {
            self.a = a
            self.b = b
            self.c = c
        }
        
        public func validate(_ value: String) -> ValidationResult {
            let a = a.validate(value)
            let b = b.validate(value)
            let c = c.validate(value)
            
            guard a.error == nil else { return a }
            guard b.error == nil else { return b }
            guard c.error == nil else { return c }
            
            return .init(value: value)
        }
    }
}
