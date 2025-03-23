//
//  PredicateBuilderHelper.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 19/3/2025.
//

import Foundation

/// Allows you to use an existing Predicate as a ``StandardPredicateExpression``
fileprivate struct VariableWrappingExpression<T>: StandardPredicateExpression {
    let predicate: Predicate<T>
    let variable: PredicateExpressions.Variable<T>
    
    func evaluate(_ bindings: PredicateBindings) throws -> Bool {
        // resolve the variable
        let value = try variable.evaluate(bindings)
        
        // create bindings for the expression of the predicate
        let innerBindings = bindings.binding(predicate.variable, to: value)
        
        return try predicate.expression.evaluate(innerBindings)
    }
}

extension Predicate {
    typealias Expression = any StandardPredicateExpression<Bool>
    
    /// Returns the result of combining the predicates using the given closure.
    ///
    /// - Parameters:
    ///   - predicates: an array of predicates to combine
    ///   - nextPartialResult: A closure that combines an accumulating expression and
    ///     an expression of the sequence into a new accumulating value, to be used
    ///     in the next call of the `nextPartialResult` closure or returned to
    ///     the caller.
    /// - Returns: The final accumulated expression. If the sequence has no elements,
    ///   the result is `initialResult`.
    static func combining<T>(
        _ predicates: [Predicate<T>],
        nextPartialResult: (Expression, Expression) -> Expression
    ) -> Predicate<T> {
        return Predicate<T>({ variable in
            let expressions = predicates.map({
                VariableWrappingExpression<T>(predicate: $0, variable: variable)
            })
            
            guard let first = expressions.first else {
                return PredicateExpressions.Value(true)
            }
            
            let closure: (any StandardPredicateExpression<Bool>, any StandardPredicateExpression<Bool>) -> any StandardPredicateExpression<Bool> = {
                nextPartialResult($0,$1)
            }
            
            return expressions.dropFirst().reduce(first, closure)
        })
    }
}

public extension Array {
    /// Joins multiple predicates with an ``PredicateExpressions.Conjunction``
    /// - Returns: A predicate evaluating to true if **all** sub-predicates evaluate to true
    func conjunction<T>() -> Predicate<T> where Element == Predicate<T> {
        func buildConjunction(lhs: some StandardPredicateExpression<Bool>, rhs: some StandardPredicateExpression<Bool>) -> any StandardPredicateExpression<Bool> {
            PredicateExpressions.Conjunction(lhs: lhs, rhs: rhs)
        }
        
        return Predicate<T>.combining(self, nextPartialResult: {
            buildConjunction(lhs: $0, rhs: $1)
        })
    }
    
    /// Joins multiple predicates with an ``PredicateExpressions.Disjunction``
    /// - Returns: A predicate evaluating to true if **any** sub-predicate evaluates to true
    func disjunction<T>() -> Predicate<T> where Element == Predicate<T> {
        func buildConjunction(lhs: some StandardPredicateExpression<Bool>, rhs: some StandardPredicateExpression<Bool>) -> any StandardPredicateExpression<Bool> {
            PredicateExpressions.Disjunction(lhs: lhs, rhs: rhs)
        }
        
        return Predicate<T>.combining(self, nextPartialResult: {
            buildConjunction(lhs: $0, rhs: $1)
        })
    }
}
