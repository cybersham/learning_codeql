/**
 * @name Cross-Language JNI Path Injection
 * @description Tracks untrusted user input passing into a native method that could lead to file system manipulation.
 * @kind path-problem
 * @problem.severity error
 * @id java/jni-path-injection
 * @tags security
 *       external/cwe/cwe-22
 */

import java
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.FlowSources  // ← replaces RemoteFlowSources

// ── 1. Define config ───────────────────────────────────────────────────────
module JniFlowConfig implements DataFlow::ConfigSig {

  predicate isSource(DataFlow::Node source) {
    source instanceof RemoteFlowSource          // works with codeql/java-all ≥ 0.8
    // If you're on a newer pack, swap the line above for:
    // source instanceof ThreatModelFlowSource
  }

  predicate isSink(DataFlow::Node sink) {
    exists(MethodCall mc |
      mc.getMethod().isNative() and
      sink.asExpr() = mc.getAnArgument()
    )
  }
}

// ── 2. Instantiate the module ──────────────────────────────────────────────
module MyFlow = TaintTracking::Global<JniFlowConfig>;

// ── 3. Import PathGraph AFTER MyFlow exists ────────────────────────────────
import MyFlow::PathGraph

// ── 4. Query ───────────────────────────────────────────────────────────────
from MyFlow::PathNode source, MyFlow::PathNode sink
where MyFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "Tainted user input flows cross-boundary into native method invocation."
