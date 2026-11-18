///| **Iterator Visitor Pattern**

///|

///| This module demonstrates the Iterator Visitor pattern in MoonBit, which provides

///| a powerful way to traverse and process expression trees with minimal boilerplate.

///|

///| The pattern consists of:

///| - A base `IterVisitor` trait with default tree traversal logic

///| - Concrete visitors that override only the methods they need

///| - Automatic recursive traversal of the expression tree

///|

///| This approach reduces code duplication by providing default implementations

///| for tree traversal, allowing visitors to focus on their specific logic.

///| **IterVisitor Trait**

///|

///| The base visitor trait that provides automatic tree traversal.

///| Each visit method returns Unit and performs side effects (printing, collecting, etc.).

///|

///| Methods:

///| - `visit`: Main entry point that dispatches to specific visit methods

///| - `visit_number`: Handles Number nodes (leaf nodes)

///|
/// - `visit_add/multiply/subtract`: Handle binary operation nodes
pub trait IterVisitor {
  /// Visit the top-level expression - entry point for traversal
  fn visit(Self, Expr) -> Unit = _

  /// Visit a Number node
  fn visit_number(Self, Int32) -> Unit = _

  /// Visit an Add node  
  fn visit_add(Self, Expr, Expr) -> Unit = _

  /// Visit a Multiply node
  fn visit_multiply(Self, Expr, Expr) -> Unit = _

  /// Visit a Subtract node
  fn visit_subtract(Self, Expr, Expr) -> Unit = _
}

///|
/// Default implementation for visit_number - does nothing by default
impl IterVisitor with fn visit_number(_, _) {

}

///|
/// Main dispatcher - routes each expression type to its specific visit method
impl IterVisitor with fn visit(self, expr) {
  match expr {
    Number(n) => self.visit_number(n)
    Add(left, right) => self.visit_add(left, right)
    Multiply(left, right) => self.visit_multiply(left, right)
    Subtract(left, right) => self.visit_subtract(left, right)
  }
}

///|
/// Default traversal for Add - visits left then right subtree
impl IterVisitor with fn visit_add(self, left, right) {
  self.visit(left)
  self.visit(right)
}

///|
/// Default traversal for Multiply - visits left then right subtree
impl IterVisitor with fn visit_multiply(self, left, right) {
  self.visit(left)
  self.visit(right)
}

///|
/// Default traversal for Subtract - visits left then right subtree
impl IterVisitor with fn visit_subtract(self, left, right) {
  self.visit(left)
  self.visit(right)
}

///| **PrintVisitor**

///|

///| A concrete visitor that collects all numbers from an expression tree

///| into a StringBuilder, separated by spaces. Demonstrates how to override

///|
/// only the leaf node handler while inheriting traversal logic.
priv struct PrintVisitor(StringBuilder)

///|
/// Override visit_number to append each number to the StringBuilder
impl IterVisitor for PrintVisitor with fn visit_number(self, n) {
  // println(n.to_string())
  self.0..write_object(n).write_string(" ")
}

///|
/// Test PrintVisitor - collects all numbers in traversal order
test {
  let printer = PrintVisitor(StringBuilder())
  IterVisitor::visit(printer, Number(1))
  IterVisitor::visit(printer, Add(Number(2), Number(3)))
  IterVisitor::visit(printer, Multiply(Number(4), Number(5)))
  IterVisitor::visit(printer, Subtract(Number(6), Number(7)))
  inspect(printer.0.to_string(), content="1 2 3 4 5 6 7 ")
}

///| **CountArrayVisitor**

///|

///| A more complex visitor that collects both operation names and numbers

///| into an array. Demonstrates overriding multiple visit methods to

///|
/// capture structural information about the expression tree.
priv struct CountArrayVisitor(Array[String])

///|
/// Collect number values as strings
impl IterVisitor for CountArrayVisitor with fn visit_number(self, n) {
  self.0.push(n.to_string())
}

///|
/// Override visit_add to record the operation before traversing children
impl IterVisitor for CountArrayVisitor with fn visit_add(self, left, right) {
  self.0.push("Add")
  IterVisitor::visit(self, left)
  IterVisitor::visit(self, right)
}

///|
/// Test CountArrayVisitor - captures both operations and values
test {
  let counter = CountArrayVisitor([])
  IterVisitor::visit(counter, Number(1))
  IterVisitor::visit(counter, Add(Number(2), Number(3)))
  IterVisitor::visit(counter, Multiply(Number(4), Number(5)))
  IterVisitor::visit(counter, Subtract(Number(6), Number(7)))
  debug_inspect(
    counter.0,
    content=(
      #|["1", "Add", "2", "3", "4", "5", "6", "7"]
    ),
  )
}

///| **Expression AST**

///|

///| Simple arithmetic expression tree supporting:

///| - Number: Integer leaf nodes

///| - Add: Binary addition

///| - Multiply: Binary multiplication

///|
/// - Subtract: Binary subtraction
pub enum Expr {
  Number(Int32)
  Add(Expr, Expr)
  Multiply(Expr, Expr)
  Subtract(Expr, Expr)
}
