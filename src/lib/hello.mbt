// Simple Arithmetic Expression AST
enum Expr {
  Number(Int)
  Add(Expr, Expr) 
  Multiply(Expr, Expr)
  Subtract(Expr, Expr)
}

// Visitor trait for evaluating expressions to integers
trait EvalVisitor {
  eval(Self, Expr) -> Int
}

// Visitor trait for converting expressions to strings
trait PrintVisitor {
  print(Self, Expr) -> String
}

// Visitor trait for counting nodes
trait CountVisitor {
  count(Self, Expr) -> Int
}

// Visitor trait for transforming expressions
trait TransformVisitor {
  transform(Self, Expr) -> Expr
}

// Concrete Visitor 1: Evaluator - calculates the result
struct Evaluator {
}

impl EvalVisitor for Evaluator with eval(self, expr) {
  match expr {
    Number(n) => n
    Add(left, right) => self.eval(left) + self.eval(right)
    Multiply(left, right) => self.eval(left) * self.eval(right)
    Subtract(left, right) => self.eval(left) - self.eval(right)
  }
}

// Concrete Visitor 2: Printer - converts to string representation
struct Printer {
}

impl PrintVisitor for Printer with print(self, expr) {
  match expr {
    Number(n) => n.to_string()
    Add(left, right) => "(" + self.print(left) + " + " + self.print(right) + ")"
    Multiply(left, right) => "(" + self.print(left) + " * " + self.print(right) + ")"
    Subtract(left, right) => "(" + self.print(left) + " - " + self.print(right) + ")"
  }
}

// Concrete Visitor 3: Node Counter - counts nodes in the AST
struct NodeCounter {
}

impl CountVisitor for NodeCounter with count(self, expr) {
  match expr {
    Number(_) => 1  // leaf node counts as 1
    Add(left, right) => 1 + self.count(left) + self.count(right)
    Multiply(left, right) => 1 + self.count(left) + self.count(right)
    Subtract(left, right) => 1 + self.count(left) + self.count(right)
  }
}

// Example of a transformation visitor that returns a new AST
struct Optimizer {
}

impl TransformVisitor for Optimizer with transform(self, expr) {
  match expr {
    Number(n) => Number(n)  // Numbers stay the same
    Add(left, right) => {
      let left_opt = self.transform(left)
      let right_opt = self.transform(right)
      
      // Optimize: 0 + x = x, x + 0 = x
      match (left_opt, right_opt) {
        (Number(0), x) => x
        (x, Number(0)) => x
        (Number(a), Number(b)) => Number(a + b)  // Constant folding
        _ => Add(left_opt, right_opt)
      }
    }
    Multiply(left, right) => {
      let left_opt = self.transform(left)
      let right_opt = self.transform(right)
      
      // Optimize: 0 * x = 0, x * 0 = 0, 1 * x = x, x * 1 = x
      match (left_opt, right_opt) {
        (Number(0), _) => Number(0)
        (_, Number(0)) => Number(0)
        (Number(1), x) => x
        (x, Number(1)) => x
        (Number(a), Number(b)) => Number(a * b)  // Constant folding
        _ => Multiply(left_opt, right_opt)
      }
    }
    Subtract(left, right) => {
      let left_opt = self.transform(left)
      let right_opt = self.transform(right)
      
      // Optimize: x - 0 = x
      match (left_opt, right_opt) {
        (x, Number(0)) => x
        (Number(a), Number(b)) => Number(a - b)  // Constant folding
        _ => Subtract(left_opt, right_opt)
      }
    }
  }
}

// Demo function showing how to use the visitors
fn demo() -> Unit {
  // Build an AST: (3 + 5) * (10 - 2)
  let expr = Multiply(
    Add(Number(3), Number(5)),
    Subtract(Number(10), Number(2))
  )
  
  // Use the evaluator visitor
  let evaluator : Evaluator = Evaluator::{}
  let result = evaluator.eval(expr)
  println("Result: " + result.to_string())  // Should print: Result: 64
  
  // Use the printer visitor  
  let printer : Printer = Printer::{}
  let string_repr = printer.print(expr)
  println("Expression: " + string_repr)  // Should print: Expression: ((3 + 5) * (10 - 2))
  
  // Use the node counter visitor
  let counter : NodeCounter = NodeCounter::{}
  let node_count = counter.count(expr)
  println("Node count: " + node_count.to_string())  // Should print: Node count: 7
}

fn demo_optimizer() -> Unit {
  // Build an AST with some optimization opportunities: (5 + 0) * (8 - 0)
  let expr = Multiply(
    Add(Number(5), Number(0)),
    Subtract(Number(8), Number(0))
  )
  
  println("Original:")
  let printer = Printer::{}
  println("  " + printer.print(expr))
  
  // Apply optimizer
  let optimizer = Optimizer::{}
  let optimized = optimizer.transform(expr)
  
  println("Optimized:")
  println("  " + printer.print(optimized))
  
  // Show the results
  let evaluator = Evaluator::{}
  println("Original result: " + evaluator.eval(expr).to_string())
  println("Optimized result: " + evaluator.eval(optimized).to_string())
}

// Additional example: A visitor that doubles all numbers
priv struct Doubler {
}

impl TransformVisitor for Doubler with transform(self, expr) {
  match expr {
    Number(n) => Number(n * 2)  // Double all numbers
    Add(left, right) => Add(self.transform(left), self.transform(right))
    Multiply(left, right) => Multiply(self.transform(left), self.transform(right))
    Subtract(left, right) => Subtract(self.transform(left), self.transform(right))
  }
}

fn demo_doubler() -> Unit {
  // Build an AST: 3 + 5
  let expr = Add(Number(3), Number(5))
  
  let printer = Printer::{}
  let evaluator = Evaluator::{}
  let doubler = Doubler::{}
  
  println("Original: " + printer.print(expr) + " = " + evaluator.eval(expr).to_string())
  
  let doubled = doubler.transform(expr)
  println("Doubled: " + printer.print(doubled) + " = " + evaluator.eval(doubled).to_string())
} 