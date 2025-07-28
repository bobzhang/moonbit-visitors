# MoonBit Iterator Visitor Pattern

A clean implementation of the **Iterator Visitor Pattern** in MoonBit, demonstrating an elegant approach to traversing and processing expression trees with minimal boilerplate code.

## 🎯 Overview

This package showcases the iterator visitor pattern using a simple arithmetic expression Abstract Syntax Tree (AST). The pattern provides automatic tree traversal with the ability to override only the specific behaviors you need, making it easy to implement various tree processing operations.

## 🏗️ Architecture

### Core Components

#### Expression AST
```moonbit
pub enum Expr {
  Number(Int)           // Numeric leaf nodes
  Add(Expr, Expr)       // Binary addition  
  Multiply(Expr, Expr)  // Binary multiplication
  Subtract(Expr, Expr)  // Binary subtraction
}
```

#### Iterator Visitor Trait
The `IterVisitor` trait provides default tree traversal logic that concrete visitors can inherit:

```moonbit
pub trait IterVisitor {
  visit(Self, Expr) -> Unit              // Main entry point
  visit_number(Self, Int) -> Unit        // Handle numbers
  visit_add(Self, Expr, Expr) -> Unit    // Handle addition
  visit_multiply(Self, Expr, Expr) -> Unit // Handle multiplication
  visit_subtract(Self, Expr, Expr) -> Unit // Handle subtraction
}
```

**Key Benefits:**
- **Automatic Traversal**: Default implementations handle recursive tree traversal
- **Selective Override**: Override only the methods you need
- **Zero Boilerplate**: No need to repeat traversal logic in each visitor
- **Side-Effect Based**: Visitors perform actions through side effects

### Example Implementations

#### PrintVisitor
Collects all numbers from an expression tree into a string:

```moonbit
priv type PrintVisitor StringBuilder

impl IterVisitor for PrintVisitor with visit_number(self, n) {
  self.inner()..write_object(n)..write_string(" ")
}
// Automatically inherits traversal for Add, Multiply, Subtract
```

#### CountArrayVisitor
Collects both operation names and numbers, demonstrating structural information capture:

```moonbit
priv type CountArrayVisitor Array[String]

impl IterVisitor for CountArrayVisitor with visit_number(self, n) {
  self.inner().push(n.to_string())
}

impl IterVisitor for CountArrayVisitor with visit_add(self, left, right) {
  self.inner().push("Add")
  self.visit(left)  // Explicit traversal after recording operation
  self.visit(right)
}
```

## 🚀 Usage Examples

### Basic Number Collection
```moonbit
// Create an expression: 2 + 3
let expr = Add(Number(2), Number(3))

// Collect all numbers
let printer : PrintVisitor = StringBuilder::new()
printer.visit(expr)
// Result: "2 3 "
```

### Structural Information Capture
```moonbit
// Create expression: 2 + 3
let expr = Add(Number(2), Number(3))

// Collect operations and numbers
let counter : CountArrayVisitor = []
counter.visit(expr)
// Result: ["Add", "2", "3"]
```

### Complex Expression Traversal
```moonbit
// Create nested expression: (4 * 5) - (6 + 7)
let expr = Subtract(
  Multiply(Number(4), Number(5)),
  Add(Number(6), Number(7))
)

let printer : PrintVisitor = StringBuilder::new()
printer.visit(expr)
// Visits all numbers in depth-first order: "4 5 6 7 "
```

## 📊 Pattern Advantages

### 🎯 Minimal Code
Write only the specific behavior you need:
```moonbit
// Visitor that counts only multiplication operations
struct MultiplyCounter { mut count : Int }

impl IterVisitor for MultiplyCounter with visit_multiply(self, left, right) {
  self.count = self.count + 1
  self.visit(left)   // Don't forget to traverse children!
  self.visit(right)
}
// That's it! Other operations automatically traverse without counting
```

### 🔧 Extensibility
Easy to add new visitors without modifying existing code:
```moonbit
// New visitor to find maximum number
struct MaxFinder { mut max : Int }

impl IterVisitor for MaxFinder with visit_number(self, n) {
  if n > self.max { self.max = n }
}
// Automatically traverses the entire tree to find all numbers
```

### 🛡️ Type Safety
MoonBit's type system ensures:
- All expression types are handled
- Visitor implementations are type-checked
- Pattern matching is exhaustive

## 🧪 Testing

The implementation includes tests demonstrating the pattern's behavior:

```moonbit
test {
  let printer : PrintVisitor = StringBuilder::new()
  printer.visit(Number(1))
  printer.visit(Add(Number(2), Number(3)))
  printer.visit(Multiply(Number(4), Number(5)))
  printer.visit(Subtract(Number(6), Number(7)))
  // Verifies output: "1 2 3 4 5 6 7 "
}

test {
  let counter : CountArrayVisitor = []
  counter.visit(Add(Number(2), Number(3)))
  // Verifies: ["Add", "2", "3"]
}
```

## 🔮 Extending the Pattern

### Adding New Expression Types
To add new operations like division:

1. Extend the Expr enum:
```moonbit
pub enum Expr {
  Number(Int)
  Add(Expr, Expr)
  Multiply(Expr, Expr)
  Subtract(Expr, Expr)
  Divide(Expr, Expr)    // New!
}
```

2. Add to the IterVisitor trait:
```moonbit
pub trait IterVisitor {
  // ... existing methods ...
  visit_divide(Self, Expr, Expr) -> Unit = _
}

// Add default traversal
impl IterVisitor with visit_divide(self, left, right) {
  self.visit(left)
  self.visit(right)
}

// Update the main dispatcher
impl IterVisitor with visit(self, expr) {
  match expr {
    // ... existing cases ...
    Divide(left, right) => self.visit_divide(left, right)
  }
}
```

### Creating Custom Visitors
Example: A visitor that collects only odd numbers:

```moonbit
struct OddCollector { numbers : Array[Int] }

impl IterVisitor for OddCollector with visit_number(self, n) {
  if n % 2 == 1 {
    self.numbers.push(n)
  }
}
// That's all! Traversal is automatic
```

## 📁 Project Structure

```
moonbit-visitors/
├── README.md              # This documentation
├── moon.mod.json          # Package configuration
├── LICENSE                # Apache 2.0 license
└── src/
    └── lib/
        ├── visitor.mbt    # Main implementation
        ├── lib.mbti       # Interface definitions
        └── moon.pkg.json  # Package metadata
```

## 🎓 Educational Value

This implementation demonstrates:

- **Design Patterns**: Clean iterator visitor pattern implementation
- **Trait-Based Design**: Leveraging MoonBit's trait system for extensibility
- **Minimal Boilerplate**: How default implementations reduce code duplication
- **Type Safety**: Using MoonBit's type system effectively
- **Testing**: Property-based testing of visitor behaviors

## 🤝 Contributing

Contributions are welcome! Consider:
- Adding new visitor examples
- Extending the expression language
- Implementing performance optimizations
- Improving documentation
- Adding more comprehensive tests

## 📄 License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

---

*Built with ❤️ using [MoonBit](https://www.moonbitlang.com/)*