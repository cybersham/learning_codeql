# Learning CodeQL: Cross-Language Vulnerability Detection

This project demonstrates how to configure **customized CodeQL queries** to detect path injection vulnerabilities across Java and C/C++ language boundaries.

## Problem Statement

Your company's system architecture:
- **Java backend**: Accepts user input through HTTP requests
- **C native extension**: Performs high-performance data transformations
- **Vulnerability**: Tainted user input from Java is passed to C code, which writes to arbitrary file paths (path injection)

**Challenge**: Standard CodeQL analysis with separate Java and C/C++ jobs fails to detect this vulnerability because:
1. Each language analysis runs in isolation
2. Taint tracking stops at language boundaries (JNI/native calls)
3. Cross-language data flow is not analyzed by default CodeQL queries

## Solution: Customized CodeQL Configuration

This repository includes:
- ✅ **Custom CodeQL queries** that trace taint across Java → C boundaries
- ✅ **Integrated CodeQL workflow** combining Java and C analysis
- ✅ **Configuration examples** for detecting path injection vulnerabilities
- ✅ **Test cases** demonstrating vulnerable patterns

## Repository Structure

```
learning_codeql/
├── README.md                              # This file
├── .github/
│   └── workflows/
│       ├── codeql-analysis-java.yml      # Java-focused analysis
│       ├── codeql-analysis-c.yml         # C/C++-focused analysis
│       └── codeql-analysis-integrated.yml # Cross-language analysis
├── queries/
│   ├── java-to-c-taint-flow.ql           # Custom taint tracking query
│   ├── path-injection-detector.ql         # Path injection detection
│   └── jni-boundary-analysis.ql           # JNI call tracking
├── src/
│   ├── java/
│   │   └── VulnerableBackend.java         # Example: Java code accepting user input
│   └── c/
│       ├── native_extension.c             # Example: C code with file write
│       └── native_extension.h
└── test/
    ├── vulnerable_examples.md             # Known vulnerable patterns
    └── safe_examples.md                   # Safe implementation patterns
```

## Why Standard CodeQL Doesn't Detect This

### Scenario: Separate Java and C Analysis

```
┌─────────────────────────────────────────────────────────────┐
│ CodeQL Job 1: Java Analysis                                 │
├─────────────────────────────────────────────────────────────┤
│ ✓ Detects: User input → String in Java                     │
│ ✗ Cannot see: String passed to native function             │
│ ✗ Blind spot: JNI boundary crossing                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    [JNI Boundary]
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ CodeQL Job 2: C/C++ Analysis                               │
├─────────────────────────────────────────────────────────────┤
│ ✗ Cannot see: Where the C-string came from (Java side)     │
│ ✓ Detects: File write using tainted buffer                 │
│ ✗ Conclusion: No vulnerable taint flow (analysis too narrow)│
└─────────────────────────────────────────────────────────────┘
```

**Result**: Neither query sees the complete data flow, so the vulnerability goes undetected.

## Custom CodeQL Configuration

### Key Customizations

#### 1. **Cross-Language Taint Tracking** (`java-to-c-taint-flow.ql`)

#### 2. **Integrated Workflow Configuration** (`.github/workflows/codeql-analysis-integrated.yml`)

### CodeQL Execution Flow

## Safe Implementation

### Input Validation Pattern

## How to Use This Repository

### 1. **Clone and Setup**
```bash
git clone https://github.com/cybersham/learning_codeql.git
cd learning_codeql
```

### 2. **Run Local CodeQL Analysis**
```bash
# Analyze Java code
codeql database create java_db --language=java --source-root=src/java

# Analyze C code
codeql database create cpp_db --language=cpp --source-root=src/c

# Run custom queries
codeql query run queries/java-to-c-taint-flow.ql --database=java_db
codeql query run queries/path-injection-detector.ql --database=cpp_db
```

### 3. **GitHub Actions Integration**
Push to the repository to trigger the integrated CodeQL workflow:
```bash
git push origin main
```

Check the **Security** → **Code scanning** tab for results.

## Key Takeaways

✅ **Customize CodeQL queries** to match your architecture  
✅ **Track taint across language boundaries** (JNI, FFI, etc.)  
✅ **Combine multiple language analyses** in a single workflow  
✅ **Create language-specific queries** for your vulnerability patterns  
✅ **Test with known vulnerable examples** to validate detection  

## References

- [CodeQL Documentation](https://codeql.github.com/docs/)
- [CodeQL Query Language Reference](https://codeql.github.com/docs/ql-language-reference/)
- [GitHub Code Scanning](https://docs.github.com/en/code-security/code-scanning/introduction-to-code-scanning)
- [Java to C/C++ JNI Security Issues](https://docs.oracle.com/en/java/javase/18/docs/specs/jni/design.html)

## Contributing

This is a learning repository. Feel free to:
- Add new vulnerable patterns
- Create additional custom queries
- Test with your own code samples
- Submit improvements

## License

MIT - Educational purposes

---

**Last Updated**: 2026-06-10  
**Maintainer**: cybersham
